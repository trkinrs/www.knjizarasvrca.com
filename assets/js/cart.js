// Korpa: čuva se u localStorage, plaćanje ide na checkout.knjizarasvrca.com.
(function() {
  var STORAGE_KEY = 'svrca-cart';
  var config = window.SVRCA_CART || {};

  function load() {
    try {
      var items = JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]');
      return Array.isArray(items) ? items : [];
    } catch (e) {
      return [];
    }
  }

  function save(items) {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(items)); } catch (e) {}
    updateBadges();
    document.dispatchEvent(new CustomEvent('cart:change'));
  }

  // Cene se računaju u parama da bi se izbegle greške zaokruživanja.
  function priceCents(item) { return Math.round(Number(item.price) * 100); }

  function totalCents(items) {
    return items.reduce(function(sum, item) { return sum + priceCents(item) * item.quantity; }, 0);
  }

  function formatMoney(cents) {
    var value = (cents / 100).toFixed(2).split('.');
    return value[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.') + ',' + value[1] + ' din.';
  }

  function clampQuantity(quantity, max) {
    quantity = Math.max(1, parseInt(quantity, 10) || 1);
    return max > 0 ? Math.min(quantity, max) : quantity;
  }

  function add(product, quantity) {
    var items = load();
    var existing = items.find(function(item) { return item.sku === product.sku; });
    if (existing) {
      existing.quantity = clampQuantity(existing.quantity + (quantity || 1), product.max);
    } else {
      items.push({
        sku: product.sku,
        name: product.name,
        price: product.price,
        url: product.url,
        max: product.max || 0,
        quantity: clampQuantity(quantity || 1, product.max)
      });
    }
    save(items);
  }

  function setQuantity(sku, quantity) {
    var items = load();
    items.forEach(function(item) {
      if (item.sku === sku) item.quantity = clampQuantity(quantity, item.max);
    });
    save(items);
  }

  function remove(sku) {
    save(load().filter(function(item) { return item.sku !== sku; }));
  }

  function clear() { save([]); }

  function count() {
    return load().reduce(function(sum, item) { return sum + item.quantity; }, 0);
  }

  function updateBadges() {
    var n = count();
    document.querySelectorAll('[data-cart-count]').forEach(function(el) {
      el.textContent = n;
      el.hidden = n === 0;
    });
  }

  // Šalje korpu na checkout kao POST formu (items kao JSON).
  function checkout() {
    var items = load();
    if (!items.length) return;

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = config.checkoutUrl || 'https://checkout.knjizarasvrca.com/checkout';

    function field(name, value) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      form.appendChild(input);
    }

    field('amount', (totalCents(items) / 100).toFixed(2));
    field('return_url', location.origin + location.pathname);
    field('items', JSON.stringify(items.map(function(item) {
      return { name: item.name, sku: item.sku, quantity: item.quantity, price: (priceCents(item) / 100).toFixed(2) };
    })));

    document.body.appendChild(form);
    form.submit();
  }

  window.SvrcaCart = {
    load: load, add: add, setQuantity: setQuantity, remove: remove, clear: clear, count: count,
    totalCents: totalCents, priceCents: priceCents, formatMoney: formatMoney, checkout: checkout
  };

  // Dugmad "Dodaj u korpu" na stranici artikla.
  document.addEventListener('click', function(e) {
    var button = e.target.closest('[data-add-to-cart]');
    if (!button) return;
    e.preventDefault();
    var quantityInput = document.querySelector(button.getAttribute('data-quantity-input') || '#cart-quantity');
    add({
      sku: button.getAttribute('data-sku'),
      name: button.getAttribute('data-name'),
      price: Number(button.getAttribute('data-price')),
      url: button.getAttribute('data-url'),
      max: parseInt(button.getAttribute('data-max'), 10) || 0
    }, quantityInput ? parseInt(quantityInput.value, 10) : 1);

    var notice = document.getElementById('cart-added');
    if (notice) notice.hidden = false;
  });

  // Promene iz drugih tabova.
  window.addEventListener('storage', function(e) {
    if (e.key === STORAGE_KEY) {
      updateBadges();
      document.dispatchEvent(new CustomEvent('cart:change'));
    }
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', updateBadges);
  } else {
    updateBadges();
  }
})();
