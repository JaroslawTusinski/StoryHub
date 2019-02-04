({
  init: function(component, event, helper) {
    var productsJson = sessionStorage.getItem('customSearch--recordProducts');

    if (!$A.util.isUndefinedOrNull(productsJson)) {
      var products = JSON.parse(productsJson);
      component.set('v.Products', JSON.parse(productsJson));
      sessionStorage.removeItem('customSearch--recordProducts');
    }
  }
})