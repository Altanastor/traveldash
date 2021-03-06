#' Create collapsible tree network diagrams.
#'
#' @param data a tree network description in one of numerous forms (see details)
#' @param width numeric width for the network graph's frame area in pixels
#' @param height height for the network graph's frame area in pixels
#' @param treeType character specifying the tree layout type. Options
#' are 'tidy' and 'cluster'.
#' @param direction character specifying the direction in which the tree layout
#' shoud grow. One of 'right', 'left', 'down', 'up', or 'radial'
#' @param linkType character specifying the link type between points. Options
#' are 'elbow' and 'diagonal'.
#' @param defaults named character vector specifying custom default node and link
#' formatting options
#' @param mouseover character specifying JavaScript code to be run on mouseover events
#' @param mouseout character specifying JavaScript code to be run on mouseout events
#' @param inbrowser logical specifying to open the plot in a new browser window
#' @param ... other arguments that will be passed on to as_treenetdf
#'
#' @importFrom jsonlite toJSON
#' @importFrom htmlwidgets createWidget
#' @importFrom htmlwidgets sizingPolicy
#' @importFrom htmlwidgets shinyWidgetOutput
#' @importFrom htmlwidgets shinyRenderWidget
#'
#' @export
#' 
treeNetwork <- function(data, width = NULL, height = NULL, treeType = 'tidy', 
                        direction = 'right', linkType = 'diagonal', 
                        defaults = NULL, mouseover = '', mouseout = '',
                        inbrowser = FALSE, ...) {

  # convert to the native data format
  data <- as_treenetdf(data, ...)

  default <- function(defaults = NULL) {
    defaults_ <-
      list(
        nodeSize = 8,
        nodeStroke = 'steelblue',
        nodeColour = 'steelblue',
        nodeSymbol = 'circle',
        nodeFont = 'sans-serif',
        nodeFontSize = 10,
        textColour = 'black',
        textOpacity = 1,
        linkColour = 'black',
        linkWidth = '1.5px'
      )
    if (missing(defaults)) {
      return(defaults_)
    } else {
      defaults <- as.list(defaults)
      names(defaults) <- sub('Color$', 'Colour', names(defaults))
      return(c(defaults, defaults_[! names(defaults_) %in% names(defaults)]))
    }
  }

  defaults <- default(defaults)

  for(i in 1:length(defaults)) {
    if (! names(defaults)[i] %in% names(data)) {
      data[names(defaults)[i]] <- defaults[i]
    }
  }

  options <- list(treeType = treeType, direction = direction,
                  linkType = linkType, mouseover = mouseover, 
                  mouseout = mouseout)
  x <- list(data = jsonlite::toJSON(data), options = options)

  # create widget
  htmlwidgets::createWidget(
    name = 'treeNetwork',
    x = x,
    width = width,
    height = height,
    package = 'nd3',
    sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress = inbrowser)
  )
}

#' Shiny bindings for treeNetwork
#'
#' Output and render functions for using treeNetwork within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a treeNetwork
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name treeNetwork-shiny
#'
#' @export
treeNetworkOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'treeNetwork', width, height, 
                                 package = 'nd3')
}

#' @rdname treeNetwork-shiny
#' @export
renderTreeNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, treeNetworkOutput, env, quoted = TRUE)
}
