{
  "acq connector => broker" => '
{
  "_interface": "icnode/V1",
  "_type": "index",
  "_rdate": "%now",
  "_idn2": "tsadin17",
  "data": [
    {
      "date": "%now",
      "value": "14683",
      "unit": "?"
    }
  ]
} 
  ',
  "acq broker => N3" => '
 
{
  "id": [
    "metier",
    "EP",
    "vendeur",
    "icnode",
    "composant",
    "acquisition"
  ],
  "timestampProduction": "%now",
  "data": [
    {
      "id": "tsadin17",
      "values": [
        {
          "k": "index",
          "v": "14683222",
          "unit": "?"
        }
      ]
    }
  ]
}
  ',
  "tc N3 => broker" => '
{
  "id": [
    "metier",
    "EP",
    "vendeur",
    "icnode",
    "composant",
    "switch"
  ],
  "timestampProduction": "%now",
  "data": [
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    },
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    },
    {
      "id": "tsadin17",
      "values": [
        { "k": "switch9", "v": "1" }
      ]
    }
  ]
}
'
}