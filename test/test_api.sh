# add birds
curl -H "Content-Type: application/json" -X POST http://localhost:7777/birds -d '{"name: "abc", "family": "pqr", "continents": ["xyz", "rst"], "visible": true}'
curl -H "Content-Type: application/json" -X POST http://localhost:7777/birds -d '{"name: "abc", "family": "pqr", "continents": ["xyz", "xyz"]}'
curl -H "Content-Type: application/json" -X POST http://localhost:7777/birds -d '{"name: "abc", "family": "pqr", "continents": ["xyz", "rst"]}'
