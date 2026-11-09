// mongosh naijamart < seed.js  (or load inside mongosh)
db = db.getSiblingDB('naijamart');
db.customers.drop(); db.sellers.drop(); db.products.drop(); db.orders.drop();

db.customers.insertMany([
 {_id:1, name:'Adaeze Okafor', email:'adaeze.okafor@example.com',
  addresses:[{line1:'12 Adeola Odeku St',city:'Lagos',state:'Lagos'}],
  created_at:new Date()},
 {_id:2, name:'Tunde Balogun', email:'tunde.balogun@example.com',
  addresses:[{line1:'45 Wuse Zone 4',city:'Abuja',state:'FCT'}],
  created_at:new Date()}
]);

db.sellers.insertMany([
 {_id:1, shop:'TechPoint NG', email:'sales@techpoint.ng', rating:4.6},
 {_id:2, shop:'Lagos Fabrics', email:'hello@lagosfabrics.ng', rating:4.3},
 {_id:3, shop:'FarmFresh', email:'orders@farmfresh.ng', rating:4.8}
]);

db.products.insertMany([
 {_id:1, seller_id:1, category:'Electronics', name:'Infinix Note 40 Pro',
  price:285000, stock:40, attributes:{ram:'8GB',storage:'256GB',colour:'Titan Gold'}},
 {_id:2, seller_id:1, category:'Electronics', name:'Oraimo PowerBank 20000mAh',
  price:18500, stock:150, attributes:{capacity:'20000mAh',fast_charge:true}},
 {_id:3, seller_id:2, category:'Fashion', name:'Ankara Fabric 6 yards',
  price:12500, stock:300, attributes:{material:'cotton',length:'6 yards'}},
 {_id:4, seller_id:3, category:'Groceries', name:'Ofada Rice 5kg',
  price:9800, stock:500, attributes:{weight:'5kg',origin:'Ogun'}},
 {_id:5, seller_id:3, category:'Home & Kitchen', name:'Palm Oil 5L',
  price:15000, stock:220, attributes:{volume:'5L'}}
]);

// Atomic stock-safe order placement (mirrors SQL guarded UPDATE)
function placeOrder(customerId, addressIdx, items){
  for (const it of items){
    const r = db.products.findOneAndUpdate(
      {_id: it.product_id, stock: {$gte: it.qty}},
      {$inc: {stock: -it.qty}});
    if (!r) throw new Error('Insufficient stock for product ' + it.product_id);
    it.price_at_purchase = r.price;
    it.name = r.name;
  }
  const total = items.reduce((s,i)=>s + i.qty*i.price_at_purchase, 0);
  db.orders.insertOne({
    customer_id: customerId,
    address: db.customers.findOne({_id:customerId}).addresses[addressIdx],
    items: items, total: total, status: 'PENDING', placed_at: new Date()
  });
}

placeOrder(1, 0, [{product_id:1, qty:1},{product_id:2, qty:2}]);
placeOrder(2, 0, [{product_id:4, qty:5}]);
print('seeded');
