library(testit)

assert('validateSelection() works', {
  (has_error(
    validateSelection(list(mode = 'a'))
  ))
  (!has_error(
    validateSelection(list(mode = 'single', target = 'row'))
  ))
  # check selected when target is row+column
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row+column'))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selected = 1))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selected = list(rows = 3:4)))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selected = list(cols = 3:4)))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selectable = 1))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selectable = list(rows = 3:4)))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row+column', selectable = list(cols = 3:4)))
  ))
  # check selected when target is cell
  (!has_error(
    validateSelection(list(mode = 'none', target = 'cell'))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'cell', selected = 1))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'cell', selected = cbind(1)))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'cell', selected = cbind(1, 2)))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'cell', selectable = 1))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'cell', selectable = cbind(1)))
  ))
  (!has_error(
    validateSelection(list(mode = 'none', target = 'cell', selectable = cbind(1, 2)))
  ))
  # selectable must be all positive or non-positive values
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row', selectable = 1:3))
  ))
  (has_error(
    validateSelection(list(mode = 'none', target = 'row', selectable = c(-1, 1)))
  ))
  # selectable supports TRUE or FALSE
  (!has_error(
    validateSelection(list(mode = 'none', target = 'row', selectable = FALSE))
  ))
})

assert('appendColumnDefs() works', {
  (appendColumnDefs(list(), 1) %==% list(columnDefs = list(1)))
  (appendColumnDefs(list(a = 1), 2) %==% list(a = 1, columnDefs = list(2)))
  (appendColumnDefs(list(columnDefs = list(1)), 2) %==% list(columnDefs = list(1, 2)))
})

assert('classNameDefinedColumns() works', {
  opt = list()
  (classNameDefinedColumns(opt, ncol = 2) %==% integer())
  # only count className defined
  opt = list(columnDefs = list(list(targets = '_all')))
  (classNameDefinedColumns(opt, ncol = 3) %==% integer())
  opt$columnDefs[[1]]$className = 'xxx'
  (classNameDefinedColumns(opt, ncol = 3) %==% 0:2)
  # negative is interpreted as right to left cols
  opt = list(columnDefs = list(list(targets = -(3:4), className = 'xxx')))
  (classNameDefinedColumns(opt, ncol = 5L) %==% 2:1)
  # not '_all' and not numeric will get ignored
  opt = list(columnDefs = list(list(targets = 'bbb', className = 'xxx')))
  (classNameDefinedColumns(opt, ncol = 5L) %==% integer())
})

assert('convertIdx() works', {
  (convertIdx(1L, c('a', 'b')) %==% 1L)
  (convertIdx(1L, c('a', 'b'), invert = TRUE) %==% -1L)
  (convertIdx(c(TRUE, FALSE), c('a', 'b')) %==% c(TRUE, FALSE))
  (convertIdx(c(TRUE, FALSE), c('a', 'b'), invert = TRUE) %==% c(FALSE, TRUE))
  (has_error(convertIdx('a', NULL), silent = TRUE))
  (convertIdx(c('b', 'd'), letters) %==% c(b = 2L, d = 4L))
  (convertIdx(c('b', 'd'), letters[1:4], invert = TRUE) %==% c(a = 1L, c = 3L))
  (has_error(convertIdx('c', c('a', 'b')), silent = TRUE))
})

assert('escapeData() works', {
  # escapeData() is designed to handle only data.frame or NULL
  # other type of inputs is undefined (may not throw error)
  (escapeData(NULL, TRUE) %==% NULL)
  (escapeData(iris, FALSE) %==% iris)
  # only escape character and factor
  data = data.frame(A = '<', B = factor('>'), C = 1, stringsAsFactors = FALSE)
  expect = data.frame(A = '&lt;', B = '&gt;', C = 1, stringsAsFactors = FALSE)
  (escapeData(data, TRUE, colnames(data)) %==% expect)
  # i to control the escape part
  (escapeData(data, FALSE, colnames(data)) %==% data)
  expect = data.frame(A = '&lt;', B = factor('>'), C = 1, stringsAsFactors = FALSE)
  (escapeData(data, c(1, 3), colnames(data)) %==% expect)
  (escapeData(data, 'A', colnames(data)) %==% expect)
})

assert('escapeColNames() works', {
  # escapeColNames() will call HTML() on those no need to escape
  # and leave alone for others as it will call tags$th() on each
  # of the elements, when those not protected by HTML() will get
  # escaped
  nms = c('<', '>', 'a')
  (escapeColNames(nms, TRUE) %==% nms)
  (escapeColNames(nms, FALSE) %==% lapply(nms, HTML))
  (escapeColNames(nms, c(1, 3)) %==% list('<', HTML('>'), 'a'))
  (escapeColNames(nms, -2) %==% list('<', HTML('>'), 'a'))
  (escapeColNames(nms, c('<', 'a')) %==% list('<', HTML('>'), 'a'))
  (escapeColNames(nms, c(TRUE, FALSE, TRUE)) %==% list('<', HTML('>'), 'a'))
})

assert('escapeToConfig() works', {
  nms = c('<', '>', 'a')
  (escapeToConfig(TRUE, nms) %==% 'true')
  (escapeToConfig(FALSE, nms) %==% 'false')
  (escapeToConfig(c(1, 3), nms) %==% '"1,3"')
  (escapeToConfig(-2, nms) %==% '"-2"')
  (escapeToConfig(c('<', 'a'), nms) %==% '"1,3"')
  (escapeToConfig(c(TRUE, FALSE, TRUE), nms) %==% '"1,3"')
})

assert('sameSign() works', {
  (sameSign(NULL) %==% TRUE)
  (sameSign(c(1, 2, 3)) %==% TRUE)
  (sameSign(c(-1, -2, -3)) %==% TRUE)
  (sameSign(c(1, -2, 3)) %==% FALSE)
  (sameSign(c(1, 0, 3)) %==% FALSE)
  (sameSign(c(1, 0, 3), zero = 1) %==% TRUE)
  (sameSign(c(1, 0, 3), zero = -1) %==% FALSE)
  (sameSign(c(-1, 0, -3)) %==% FALSE)
  (sameSign(c(-1, 0, -3), zero = 1) %==% FALSE)
  (sameSign(c(-1, 0, -3), zero = -1) %==% TRUE)
  (sameSign(c(0, 0, 0)) %==% TRUE)
  (sameSign(c(0, 0, 0), zero = -1) %==% TRUE)
  (sameSign(list(1:3, -(1:3))) %==% TRUE)
  (sameSign(list(c(1, -1, 3), -(1:3))) %==% FALSE)
  (sameSign(cbind(1:2, 3:4)) %==% TRUE)
  (sameSign(cbind(1:2, -(1:2))) %==% FALSE)
})

local({
  opt = options('DT.datatable.shiny' = TRUE)
  on.exit(options(opt), add = TRUE)
  assert('selection$selectable must be NULL or all pos/neg values', {
    (!has_error(datatable(iris, selection = list(selectable = FALSE))))
    (has_error(datatable(iris, selection = list(selectable = c(1, -1)))))
    (has_error(datatable(iris, selection = list(selectable = list(rows = 1:3, cols = c(1, 0))))))
    (!has_error(datatable(iris, selection = list(selectable = 1:3))))
    (!has_error(datatable(iris, selection = list(selectable = NULL))))
    (!has_error(datatable(iris, selection = list(selectable = list(rows = -1)))))
  })
  assert('selection option will keep NULL elements', {
    # to ensure on JS side, the value like data.selection.selectable is null instead of undefined
    out = datatable(iris, selection = list(selectable = NULL, selected = NULL))
    (names(out$x$selection) %==% c('mode', 'selected', 'target', 'selectable'))
  })
})
