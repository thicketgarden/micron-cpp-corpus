`c`[🧭 Turn-by-turn directions`:/page/directions.mu]`a

`c`F38frns-geo`f
`c`F999Geolocation data over Reticulum`f
`a
-

`F666meshapi 0.1  ·  rnsgeo / query  ·  path q`f
`F666dest 2b20a86bfaf43c75810372dd73a53d1c`f

Geocoding, routing, snap-to-road and nearby-POI lookups over an authenticated Reticulum Link. Responses are trimmed compact enough for LoRa. Backed by OSRM, Nominatim and Overpass. Map tiles are not served over the mesh (too heavy); this is data only. Coordinates are decimal degrees (WGS84).

`F666auth: `F6a6public`f`F666 = anyone may call · `Fd92identity`f`F666 = identified client required · `Fd92allow-list`f`F666 = approved identities only`f

-
>>rev  Reverse geocode a coordinate to a place   auth: `F6a6public`f

`Faaalat`f  `F666float, required`f   latitude in decimal degrees
`B333`<24|rev_lat`>`b
`Faaalon`f  `F666float, required`f   longitude in decimal degrees
`B333`<24|rev_lon`>`b
`[  run  `:/page/index.mu`rev_lat|rev_lon]
`F888→ returns { label: str, lat: float, lon: float }`f

-
>>fwd  Forward geocode: place text to coordinates   auth: `F6a6public`f

`Faaaq`f  `F666str, required`f   free-text place/address query
`B333`<24|fwd_q`>`b
`Faaalimit`f  `F666int, max 5`f   max results (1-5, default 1)
`B333`<24|fwd_limit`>`b
`[  run  `:/page/index.mu`fwd_q|fwd_limit]
`F888→ returns [{lat,lon,label}]`f

-
>>route  Driving route between two points   auth: `F6a6public`f

`Faaafrm`f  `F666[lat,lon], required`f   start point as lat,lon
`B333`<24|route_frm`>`b
`Faaato`f  `F666[lat,lon], required`f   end point as lat,lon
`B333`<24|route_to`>`b
`Faaageom`f  `F666bool`f   include encoded polyline geometry (default false)
`B333`<24|route_geom`>`b
`[  run  `:/page/index.mu`route_frm|route_to|route_geom]
`F888→ returns { dist_m: int, dur_s: int, poly: str? }`f

-
>>near  Snap a coordinate to the nearest road   auth: `F6a6public`f

`Faaalat`f  `F666float, required`f   latitude in decimal degrees
`B333`<24|near_lat`>`b
`Faaalon`f  `F666float, required`f   longitude in decimal degrees
`B333`<24|near_lon`>`b
`[  run  `:/page/index.mu`near_lat|near_lon]
`F888→ returns { lat: float, lon: float, name: str? }`f

-
>>poi  Named points of interest near a coordinate   auth: `F6a6public`f

`Faaalat`f  `F666float, required`f   center latitude
`B333`<24|poi_lat`>`b
`Faaalon`f  `F666float, required`f   center longitude
`B333`<24|poi_lon`>`b
`Faaaradius`f  `F666int, max 3000`f   search radius in metres (max 3000)
`B333`<24|poi_radius`>`b
`Faaacat`f  `F666str, optional`f   filter, e.g. amenity=cafe (optional)
`B333`<24|poi_cat`>`b
`Faaalimit`f  `F666int, max 30`f   max results (max 30)
`B333`<24|poi_limit`>`b
`[  run  `:/page/index.mu`poi_lat|poi_lon|poi_radius|poi_cat|poi_limit]
`F888→ returns [{name,lat,lon,cat}]`f

-
>>place  Best place match with contact info (for a place card)   auth: `F6a6public`f

`Faaaq`f  `F666str, required`f   place/POI/address text
`B333`<24|place_q`>`b
`[  run  `:/page/index.mu`place_q]
`F888→ returns { lat: float, lon: float, label: str, name: str, cls: str, type: str, importance: float, contact: {phone?,website?,hours?} }`f

-
>>dir  Turn-by-turn driving directions   auth: `F6a6public`f

`Faaaq_from`f  `F666str, optional`f   start place/address text (geocoded); or use frm
`B333`<24|dir_q_from`>`b
`Faaaq_to`f  `F666str, optional`f   destination place/address text (geocoded); or use to
`B333`<24|dir_q_to`>`b
`Faaafrm`f  `F666[lat,lon], optional`f   start coordinate (instead of q_from)
`B333`<24|dir_frm`>`b
`Faaato`f  `F666[lat,lon], optional`f   destination coordinate (instead of q_to)
`B333`<24|dir_to`>`b
`[  run  `:/page/index.mu`dir_q_from|dir_q_to|dir_frm|dir_to]
`F888→ returns { dist_m: int, dur_s: int, from_label: str?, to_label: str?, steps: [{text,dist_m}] }`f

-
`Faaa Source`f   https://github.com/wdunn001/rns-geo
`c`F666Created with `[MeshAPI`4c60b2d0896a80a31a506d67f0b008f2:/page/index.mu]`f

