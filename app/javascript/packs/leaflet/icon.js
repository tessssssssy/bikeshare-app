import L from 'leaflet'
import "leaflet/dist/leaflet.css"
import icon1 from "./bike-icon.png"
import shadow from "leaflet/dist/images/marker-shadow.png"

export const icon = L.icon({
  iconUrl:  icon1,  
  shadowUrl: shadow,
  iconSize: [28,42],
  iconAnchor: [12,36]
})


