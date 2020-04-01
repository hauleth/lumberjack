const evtSrc = new EventSource('/stream')
const logList = document.getElementById("logs")
const autoscroll = document.getElementById("autoscroll")

let id = undefined

const createRow = function (data) {
  const row = document.createElement("tr")

  for (const entry of data) {
    const column = document.createElement("td")
    const classes = entry.classes || []
    column.classList.add(...classes)
    column.innerText = entry.data
    row.appendChild(column)
  }

  return row;
}

evtSrc.addEventListener("log", (event) => {
  const log = JSON.parse(event.data)
  const time = new Date(log.timestamp/1000)

  const row = createRow([
    {classes: ['src'], data: log.source},
    {classes: ['tms'], data: time.toTimeString()},
    {classes: ['lvl'], data: log.data.level},
    {classes: ['msg'], data: log.data.msg}
  ])

  row.classList.add(log.data.level)
  logList.appendChild(row)

  if (autoscroll.checked) {
    if (id) window.cancelAnimationFrame(id)

    id = window.requestAnimationFrame(() => window.scrollTo(0, document.body.scrollHeight))
  }
})
