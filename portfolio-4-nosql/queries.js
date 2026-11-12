db = db.getSiblingDB('naijamart');

// Q1: order document (single-read page)
db.orders.find({customer_id:1}).sort({placed_at:-1}).pretty();

// Q2: product catalog filter on embedded attributes
db.products.find({'attributes.ram':'8GB'});

// Q3: revenue per seller — aggregation pipeline over embedded items
db.orders.aggregate([
  {$unwind:'$items'},
  {$lookup:{from:'products',localField:'items.product_id',
            foreignField:'_id',as:'prod'}},
  {$unwind:'$prod'},
  {$group:{_id:'$prod.seller_id',
           revenue:{$sum:{$multiply:['$items.qty','$items.price_at_purchase']}},
           units:{$sum:'$items.qty'}}},
  {$lookup:{from:'sellers',localField:'_id',foreignField:'_id',as:'seller'}},
  {$unwind:'$seller'},
  {$project:{shop:'$seller.shop',revenue:1,units:1}},
  {$sort:{revenue:-1}}
]);

// Q4: low-stock alert (text index + filter)
db.products.createIndex({name:'text'});
db.products.find({stock:{$lt:20}});
