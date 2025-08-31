#' @title Discover All Indirect Effects (x.boot-inspired)
#'
#' @description Automatically discovers all possible indirect effects in a 
#' structural equation model using graph traversal algorithms. This function
#' is inspired by Christian Dorri's x.boot extension concept for comprehensive
#' indirect effect identification.
#'
#' @param model A lavaan model syntax string or fitted lavaan object
#' @param max_chain_length Maximum length of indirect effect chains to discover.
#'   Default is 5. Higher values increase computational complexity.
#' @param exclude_bidirectional Logical, whether to exclude bidirectional paths
#'   (covariances) from indirect effect chains. Default is TRUE.
#' @param computational_limit Maximum number of indirect effects to discover
#'   before stopping (performance safeguard). Default is 1000.
#' @param min_chain_length Minimum length of indirect effect chains. Default is 2
#'   (at least one mediator).
#' @param verbose Logical, whether to print progress information. Default is FALSE.
#'
#' @return A named list suitable for use with write_lavaan()'s indirect argument,
#'   containing all discovered indirect effects as path products.
#'
#' @details
#' This function implements a comprehensive indirect effect discovery algorithm
#' that:
#' 
#' 1. Parses the lavaan model into a directed graph structure
#' 2. Identifies all possible indirect pathways using depth-first search  
#' 3. Generates lavaan syntax for discovered indirect effects
#' 4. Provides performance safeguards for large models
#' 
#' Unlike the existing write_lavaan() automatic indirect effects (which require
#' structured IV/M/DV specification), this function discovers ALL indirect
#' effects automatically, similar to commercial SEM software like Amos.
#' 
#' Computational complexity increases exponentially with model size and
#' max_chain_length. Use computational_limit and max_chain_length to control
#' performance.
#'
#' @export
#' @examples
#' \dontrun{
#' # Simple mediation model
#' model_syntax <- '
#'   # Regressions
#'   m ~ a*x
#'   y ~ b*m + c*x
#' '
#' 
#' # Discover all indirect effects
#' indirect_effects <- discover_all_indirect_effects(model_syntax)
#' 
#' # Use with write_lavaan()
#' full_model <- write_lavaan(
#'   custom = model_syntax,
#'   indirect = indirect_effects
#' )
#' }
discover_all_indirect_effects <- function(model,
                                        max_chain_length = 5,
                                        exclude_bidirectional = TRUE,
                                        computational_limit = 1000,
                                        min_chain_length = 2,
                                        verbose = FALSE) {
  
  # Validate inputs
  if (max_chain_length < min_chain_length) {
    stop("max_chain_length must be >= min_chain_length")
  }
  
  if (min_chain_length < 2) {
    stop("min_chain_length must be >= 2 for indirect effects")
  }
  
  # Parse model to extract relationships
  if (verbose) cat("Parsing model structure...\n")
  graph_info <- .parse_model_to_graph(model, exclude_bidirectional)
  
  # Discover all indirect paths
  if (verbose) cat("Discovering indirect pathways...\n")
  indirect_paths <- .find_all_indirect_paths(
    graph_info,
    max_chain_length = max_chain_length,
    min_chain_length = min_chain_length,
    computational_limit = computational_limit,
    verbose = verbose
  )
  
  # Generate lavaan syntax for indirect effects  
  if (verbose) cat("Generating lavaan indirect effect syntax...\n")
  indirect_effects <- .generate_indirect_syntax(indirect_paths)
  
  if (verbose) {
    cat(sprintf("Discovered %d indirect effects\n", length(indirect_effects)))
  }
  
  return(indirect_effects)
}

#' Parse lavaan model into graph structure
#' @param model lavaan model syntax or fitted object
#' @param exclude_bidirectional whether to exclude covariances
#' @return list with nodes and edges information
.parse_model_to_graph <- function(model, exclude_bidirectional = TRUE) {
  
  # Handle different input types
  if (inherits(model, "lavaan")) {
    model_syntax <- lavaan::lavInspect(model, "model.syntax")
  } else {
    model_syntax <- as.character(model)
  }
  
  # Split model into lines and clean
  lines <- unlist(strsplit(model_syntax, "\n"))
  lines <- trimws(lines)
  lines <- lines[lines != "" & !grepl("^#", lines)]
  
  # Initialize graph structures
  nodes <- character(0)
  edges <- data.frame(
    from = character(0),
    to = character(0), 
    type = character(0),
    label = character(0),
    stringsAsFactors = FALSE
  )
  
  # Parse each line
  for (line in lines) {
    
    # Skip empty lines and comments
    if (line == "" || grepl("^#", line)) next
    
    # Regression relationships: y ~ x
    if (grepl("~", line) && !grepl("~~", line) && !grepl("=~", line)) {
      parsed <- .parse_regression_line(line)
      edges <- rbind(edges, parsed$edges)
      nodes <- unique(c(nodes, parsed$nodes))
    }
    
    # Latent variable definitions: f =~ x1 + x2
    if (grepl("=~", line)) {
      parsed <- .parse_latent_line(line)  
      edges <- rbind(edges, parsed$edges)
      nodes <- unique(c(nodes, parsed$nodes))
    }
    
    # Covariances: x1 ~~ x2 (only if not excluding)
    if (grepl("~~", line) && !exclude_bidirectional) {
      parsed <- .parse_covariance_line(line)
      edges <- rbind(edges, parsed$edges) 
      nodes <- unique(c(nodes, parsed$nodes))
    }
  }
  
  return(list(nodes = nodes, edges = edges))
}

#' Parse regression line into edges
#' @param line regression line from lavaan syntax
#' @return list with edges and nodes
.parse_regression_line <- function(line) {
  
  # Split on ~
  parts <- unlist(strsplit(line, "~"))
  if (length(parts) != 2) return(list(edges = data.frame(), nodes = character(0)))
  
  lhs <- trimws(parts[1])
  rhs <- trimws(parts[2])
  
  # Parse right-hand side predictors
  predictors <- .parse_variable_list(rhs)
  
  # Create edges for each predictor -> outcome  
  edges <- data.frame(
    from = predictors$variables,
    to = rep(lhs, length(predictors$variables)),
    type = rep("regression", length(predictors$variables)),
    label = predictors$labels,
    stringsAsFactors = FALSE
  )
  
  nodes <- unique(c(lhs, predictors$variables))
  
  return(list(edges = edges, nodes = nodes))
}

#' Parse latent variable line into edges  
#' @param line latent variable line from lavaan syntax
#' @return list with edges and nodes
.parse_latent_line <- function(line) {
  
  # Split on =~
  parts <- unlist(strsplit(line, "=~"))
  if (length(parts) != 2) return(list(edges = data.frame(), nodes = character(0)))
  
  lhs <- trimws(parts[1]) 
  rhs <- trimws(parts[2])
  
  # Parse indicators
  indicators <- .parse_variable_list(rhs)
  
  # Create edges for latent -> indicator
  edges <- data.frame(
    from = rep(lhs, length(indicators$variables)),
    to = indicators$variables,
    type = rep("measurement", length(indicators$variables)), 
    label = indicators$labels,
    stringsAsFactors = FALSE
  )
  
  nodes <- unique(c(lhs, indicators$variables))
  
  return(list(edges = edges, nodes = nodes))
}

#' Parse covariance line into edges
#' @param line covariance line from lavaan syntax  
#' @return list with edges and nodes
.parse_covariance_line <- function(line) {
  
  # Split on ~~
  parts <- unlist(strsplit(line, "~~"))
  if (length(parts) != 2) return(list(edges = data.frame(), nodes = character(0)))
  
  var1 <- trimws(parts[1])
  var2_with_label <- trimws(parts[2])
  
  # Parse potential label
  var2_parsed <- .parse_variable_list(var2_with_label)
  var2 <- var2_parsed$variables[1]
  label <- var2_parsed$labels[1]
  
  # Create bidirectional edges for covariances
  edges <- data.frame(
    from = c(var1, var2),
    to = c(var2, var1),
    type = rep("covariance", 2),
    label = rep(label, 2),
    stringsAsFactors = FALSE
  )
  
  nodes <- c(var1, var2)
  
  return(list(edges = edges, nodes = nodes))
}

#' Parse variable list with potential labels
#' @param var_string string containing variables and labels  
#' @return list with variables and labels
.parse_variable_list <- function(var_string) {
  
  # Split on + to get individual terms
  terms <- unlist(strsplit(var_string, "\\+"))
  terms <- trimws(terms)
  
  variables <- character(length(terms))
  labels <- character(length(terms))
  
  for (i in seq_along(terms)) {
    term <- terms[i]
    
    # Check for label (e.g., "a*x" or "x" or "1*x")  
    if (grepl("\\*", term)) {
      parts <- unlist(strsplit(term, "\\*"))
      labels[i] <- trimws(parts[1])
      variables[i] <- trimws(parts[2])
    } else {
      labels[i] <- ""
      variables[i] <- term
    }
  }
  
  return(list(variables = variables, labels = labels))
}

#' Find all indirect paths in the graph
#' @param graph_info list with nodes and edges
#' @param max_chain_length maximum path length
#' @param min_chain_length minimum path length  
#' @param computational_limit maximum paths to find
#' @param verbose whether to print progress
#' @return list of indirect paths
.find_all_indirect_paths <- function(graph_info, 
                                   max_chain_length = 5,
                                   min_chain_length = 2,
                                   computational_limit = 1000,
                                   verbose = FALSE) {
  
  edges <- graph_info$edges
  nodes <- graph_info$nodes
  
  # Only consider structural relationships for indirect effects
  structural_edges <- edges[edges$type %in% c("regression"), ]
  
  if (nrow(structural_edges) == 0) {
    return(list())
  }
  
  # Find all paths using depth-first search
  all_paths <- list()
  path_count <- 0
  
  # Start from each node
  for (start_node in nodes) {
    if (path_count >= computational_limit) break
    
    # Find paths starting from this node
    paths_from_node <- .dfs_find_paths(
      start_node, 
      structural_edges, 
      max_depth = max_chain_length,
      current_path = character(0),
      visited = character(0)
    )
    
    # Filter by minimum length and add to results
    valid_paths <- paths_from_node[sapply(paths_from_node, length) >= min_chain_length]
    
    if (length(valid_paths) > 0) {
      all_paths <- c(all_paths, valid_paths)
      path_count <- path_count + length(valid_paths)
      
      if (verbose && path_count %% 50 == 0) {
        cat(sprintf("Found %d indirect paths...\n", path_count))
      }
    }
    
    if (path_count >= computational_limit) {
      if (verbose) {
        cat(sprintf("Reached computational limit of %d paths\n", computational_limit))
      }
      break
    }
  }
  
  return(all_paths)
}

#' Depth-first search to find paths
#' @param current_node current node in traversal
#' @param edges edge dataframe
#' @param max_depth maximum search depth  
#' @param current_path current path being built
#' @param visited nodes already visited in current path
#' @return list of paths
.dfs_find_paths <- function(current_node, edges, max_depth, current_path, visited) {
  
  # Add current node to path and visited
  new_path <- c(current_path, current_node)
  new_visited <- c(visited, current_node)
  
  # Base case: reached maximum depth
  if (length(new_path) > max_depth) {
    return(list())
  }
  
  # Find outgoing edges from current node
  outgoing <- edges[edges$from == current_node, ]
  
  if (nrow(outgoing) == 0) {
    # Terminal node - return path if it has at least 2 nodes
    if (length(new_path) >= 2) {
      return(list(new_path))
    } else {
      return(list())
    }
  }
  
  # Recursive case: explore each outgoing edge
  all_paths <- list()
  
  for (i in seq_len(nrow(outgoing))) {
    next_node <- outgoing$to[i]
    
    # Avoid cycles
    if (!next_node %in% new_visited) {
      sub_paths <- .dfs_find_paths(
        next_node, 
        edges, 
        max_depth, 
        new_path, 
        new_visited
      )
      all_paths <- c(all_paths, sub_paths)
    }
  }
  
  # Also include current path if it's long enough
  if (length(new_path) >= 2) {
    all_paths <- c(list(new_path), all_paths)
  }
  
  return(all_paths)
}

#' Generate lavaan syntax for indirect effects
#' @param indirect_paths list of paths
#' @return named list of indirect effect definitions
.generate_indirect_syntax <- function(indirect_paths) {
  
  if (length(indirect_paths) == 0) {
    return(list())
  }
  
  indirect_effects <- list()
  
  for (i in seq_along(indirect_paths)) {
    path <- indirect_paths[[i]]
    
    if (length(path) < 2) next
    
    # Create path name 
    path_name <- paste(path, collapse = "_")
    
    # Create path product syntax
    path_segments <- character(length(path) - 1)
    for (j in seq_len(length(path) - 1)) {
      path_segments[j] <- paste0(path[j], "_", path[j + 1])
    }
    
    # Join with multiplication 
    path_product <- paste(path_segments, collapse = " * ")
    
    indirect_effects[[path_name]] <- path_product
  }
  
  # Remove duplicates
  indirect_effects <- indirect_effects[!duplicated(indirect_effects)]
  
  return(indirect_effects)
}