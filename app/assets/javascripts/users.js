$( document ).on('turbolinks:load', function() {
  $("input[name='view_type']").change(function(){
    if ($(this).val() == 'cards')
    {
      $('#cardview').show();
      $('#listview').hide();
    }
    else
      {
        $('#cardview').hide();
        $('#listview').show();
      }
  });
})
