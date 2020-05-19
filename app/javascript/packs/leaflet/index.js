import { icon } from './icon'
import { tileLayer } from './tileLayer'

// const renderMap = async (e) => {
//   // if (!map) {
//   //   e.preventDefault()
//   // }
//   const response = await fetch(`/listings?type=json`)
//   const { data } = await response.json()
//   const map = await tileLayer(data)
//   const markers = data.map((location) => {
//     return L.marker([location[0], location[1]], {icon: icon})
//   })
//   L.featureGroup(markers).addTo(map)
// }

// // const button = document.querySelector('#search-button')
// // button.addEventListener('click', renderMap)

// renderMap()

const renderMap = async (search) => {
  const url = search ? `/listings/map/${search}` : `/listings?type=json`
  const response = await fetch(url)
  const { data, center } = await response.json()
  const map = await tileLayer(center)
  const markers = data.map((location) => {
    return L.marker([location[0], location[1]], {icon: icon })
  })
  L.featureGroup(markers).addTo(map)
  submit.disabled = false
}


const search = document.querySelector("#search-form")
const submit = document.querySelector("#search-button")
const field = document.querySelector("#search-field")

search.addEventListener('submit', async (e) => {
  e.preventDefault()
  
  console.log('Hello')
  map.remove()
  document.querySelector(".map-container").innerHTML = `<div style="height: 700px; width: 500px;" id="map"></div>`
  const value = e.target.elements[0].value
  renderMap(value)
})

renderMap(field.value)
console.log(field.value)

