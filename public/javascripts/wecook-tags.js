$(document).ready(function(){

    $('.tag_x').click(function(event) {
        var tag = $(this).parent().text();
        var user_recipe_id = $(this).parent().parent().parent().attr('id').replace("tag_user_recipe_","");
        // fix this later. this will break if we ever change routes.
        var url = "/recipes/" +user_recipe_id + "/delete_tag";
        $.ajax({
            type: 'POST',
            url:  url,
            context: $(this).parent(),
            data: 'tag=' + tag,
            dataType: 'json',
            statusCode: {
                200: function(){
                    $(this).remove();
                },
                500: function() {
                    alert("Could do not delete tag!");
                }
            }
        });

    });

    $('.tag_text_box').keypress(function(e) {
        if(e.which == 13) {
            var tag = $(this).val();
            if (tag == ''){
                return;
            }
            var user_recipe_id = $(this).parent().attr('id').replace("tag_user_recipe_","");
            var url = "/recipes/" +user_recipe_id + "/add_tag";
            $.ajax({
            type: 'POST',
            url:  url,
            context: $(this),
            data: 'tag=' + tag,
            dataType: 'json',
            statusCode: {
                200: function(data){
                    if (data['added']) {
                        add_tag(tag, $(this).prev());
                    }
                    $(this).val('');
                },
                500: function() {
                    alert("Could do not add tag!");
                }
            }
        });
        }
    });

    $('.tag_plus').click(function(event) {
       $(this).prev().show().focus();
    });

//    $('.tag_text_box').tagit();
//    $('.tag_text_box').hide();

    $('.tag_text_box').hide();
    $('.tag_text_box').focusout(function(){
        $(this).hide();
    });

    // The dom looks like this:
    // <span>
    // <span>summer<span>x</span></span>
    // <span>salad<span>x</span></span>
    // </span>
    // element points to the parent span.
    function add_tag(tag, element){
        var new_node = element.children().last().clone(true);
        // at this point new node is pointing to <span>oldtag<span>x</span></span>
        // I dive into the native dom element (new_node.get(0))
        // then get the first child (the text node 'oldtag') and replace it with a new tag + a ' '!
        // is this really a kosher way of changing the text of the span?
        new_node.get(0).childNodes[0].data = tag + ' ';
        element.append(new_node);
        //element.append('<span class="tag"> ' + tag + ' <span class="tag_x"></span></span>');
    }
});
