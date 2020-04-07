// Message handling

const evtSrc = new EventSource('/stream')
const $logs = document.getElementById('logs')
const $autoscroll = document.getElementById('autoscroll')

let id = undefined

const createRow = function (data) {
  const $row = document.createElement('tr')

  for (const entry of data) {
    const $column = document.createElement('td')
    const classes = entry.classes || []
    $column.classList.add(...classes)
    $column.innerText = entry.data
    $row.appendChild($column)
  }

  return $row;
}

evtSrc.addEventListener('log', (event) => {
  const log = JSON.parse(event.data)
  const time = new Date(log.timestamp/1000)

  const $row = createRow([
    {classes: ['src'], data: log.source},
    {classes: ['tms'], data: time.toTimeString()},
    {classes: ['lvl'], data: log.data.level},
    {classes: ['msg'], data: log.data.msg}
  ])

  $row.dataset.metadata = JSON.stringify(log.data.meta)
  $row.classList.add(log.data.level)
  $logs.appendChild($row)

  if ($autoscroll.checked) {
    if (id) window.cancelAnimationFrame(id)

    id = window.requestAnimationFrame(() => {
      window.scrollTo(0, document.body.scrollHeight)
      $autoscroll.checked = true
    })
  }
})

// Show/hide sources

const $style = document.createElement('style')
const $showSources = document.getElementById('show_sources')

document.head.appendChild($style)

$showSources.addEventListener('change', () => {
  if (!$showSources.checked && $style.sheet.rules[0]) {
    $style.sheet.deleteRule(0)
  } else {
    $style.sheet.insertRule('table .src { display: table-cell; }', 0)
  }
})

// Theme toggle

const $light = document.getElementById('light')

$light.addEventListener('change', () => {
  if ($light.checked) {
    document.body.classList.add('light')
  } else {
    document.body.classList.remove('light')
  }
})

// Modal

const $modal = document.getElementById('modal')
const $json = document.createElement('pre')

$modal.appendChild($json)

$modal.addEventListener('click', () => $modal.hidden = true)

$logs.addEventListener('click', event => {
  const meta = JSON.parse(event.target.parentNode.dataset.metadata)

  $modal.hidden = false
  $json.innerText = JSON.stringify(meta, null, 2)
})
