import L from 'leaflet'
import "leaflet/dist/leaflet.css"
import icon1 from "leaflet/dist/images/marker-icon.png"
import shadow from "leaflet/dist/images/marker-shadow.png"

export const icon = L.icon({
  iconUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Bicycle.svg/1200px-Bicycle.svg.png',
  shadowUrl: shadow,
  iconSize: [36,24],
  iconAnchor: [12,36]
})

