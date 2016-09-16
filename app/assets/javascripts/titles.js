$( document ).on('turbolinks:load', function() {
  $('.edit_title input[type=submit]').remove();
  $('.edit_title input[type=checkbox]').click(function() {
     $(this).parent('form').submit();

  });
})
