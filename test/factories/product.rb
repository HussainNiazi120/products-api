# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    asin { 'B0932QJ2JZ' }
    brand { 'Apple' }
    name { 'Apple AirTag 4 Pack' }
    length { 1.905 }
    width { 8.4074 }
    height { 12.9032 }
    weight { 0.091 }
    images do
      [
        'https://m.media-amazon.com/images/I/31iSShk0A5S.jpg',
        'https://m.media-amazon.com/images/I/31iSShk0A5S._SL75_.jpg',
        'https://m.media-amazon.com/images/I/71gY9E+cTaS.jpg',
        'https://m.media-amazon.com/images/I/31-aH0bzOSS.jpg',
        'https://m.media-amazon.com/images/I/31-aH0bzOSS._SL75_.jpg',
        'https://m.media-amazon.com/images/I/71JJueCRWJS.jpg',
        'https://m.media-amazon.com/images/I/51-6Scr6lwS.jpg',
        'https://m.media-amazon.com/images/I/51-6Scr6lwS._SL75_.jpg',
        'https://m.media-amazon.com/images/I/91bsFWILPGS.jpg',
        'https://m.media-amazon.com/images/I/41TO7qTMkeS.jpg',
        'https://m.media-amazon.com/images/I/41TO7qTMkeS._SL75_.jpg',
        'https://m.media-amazon.com/images/I/81Lq1AfCYpS.jpg',
        'https://m.media-amazon.com/images/I/41i44CHxbXS.jpg',
        'https://m.media-amazon.com/images/I/41i44CHxbXS._SL75_.jpg',
        'https://m.media-amazon.com/images/I/71ZMyXWM9CS.jpg',
        'https://m.media-amazon.com/images/I/41pxCWSRdyS.jpg',
        'https://m.media-amazon.com/images/I/41pxCWSRdyS._SL75_.jpg',
        'https://m.media-amazon.com/images/I/71YziLCAJSS.jpg'
      ]
    end
    bullet_points do
      [
        'Keep track of and find your items alongside friends and devices in the Find My app',
        'Simple one-tap setup instantly connects AirTag with your iPhone or iPad',
        'Play a sound on the built-in speaker to help find your things, or just ask Siri for help',
        'Precision Finding with Ultra Wideband technology leads you right to your nearby AirTag (on select iPhone models)',
        'Find items further away with the help of hundreds of millions of Apple devices in the Find My network',
        'Put AirTag into Lost Mode to be automatically notified when it’s detected in the Find My network',
        'All communication with the Find My network is anonymous and encrypted for privacy, Location data and history are never stored on AirTag',
        'Replaceable battery lasts over a year',
        'AirTag is IP67 water and dust resistant',
        'Make AirTag yours with a range of colorful accessories, sold separately'
      ]
    end
    description { 'Product Description' }
    price { 79 }
    price_updated_at { '2024-04-29T18:44:06.261908Z' }
    product_updated_at { nil }
    is_prime { false }
  end
end
