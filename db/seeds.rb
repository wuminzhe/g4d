# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Network.create(
  [
    { id: 1, chain_id: '0x2c', name: 'crab', subscan: 'https://crab.subscan.io/' },
    { id: 2, chain_id: '0x2e', name: 'darwinia', subscan: 'https://darwinia.subscan.io/' },
    { id: 3, chain_id: '0x2b', name: 'pangolin', subscan: 'https://pangolin.subscan.io/' },
    { id: 4, chain_id: '0x2d', name: 'pangoro', subscan: 'https://pangoro.subscan.io/' }
  ]
)
