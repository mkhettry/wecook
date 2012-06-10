$(document).ready(function(){

//    $('.tag').button();

    $('.tag_name').click(function(event) {
        var tag = $(this).text().trim();
        var uri = new jsUri(document.URL);
        var tagParams = uri.getQueryParamValue('tag');
        if (tagParams) {
            var tagParamArray = tagParams.split(',');
            if ($.inArray(tag, tagParamArray) === -1) {
                tagParams += (',' + tag);
            }
        } else {
            tagParams = tag;
        }
        uri.deleteQueryParam('page');
        uri.deleteQueryParam('tag');

        uri.addQueryParam('tag', tagParams);
        window.location = uri.toString();
    });


    $('.tag_x').click(function(event) {
        var tag = $.trim($(this).parent().text());
        tag = $.trim(tag.substring(0, tag.length - 1));//to remove the x at the end
        var user_recipe_id = $(this).attr('user_recipe_id');
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

    $('.tag-text-box').keypress(function(e) {
        if(e.which == 13) {
            var tag = $(this).val();
            if (tag == ''){
                return;
            }
//            var user_recipe_id = $(this).parent().attr('id').replace("tag_user_recipe_","");
            var user_recipe_id = $(this).attr('user_recipe_id');
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

    $('.tag-text-box').hide();

    $('.tag_hide').hide();

    $('.tag-text-box').focusout(function(){
        $(this).hide();
    });

    $('.tag-button-text').button();



    // The dom looks like this:
    // <span>
    // <span>summer<span>x</span></span>
    // <span>salad<span>x</span></span>
    // </span>
    // element points to the parent span.
    function add_tag(tag, element){
        var new_node = element.children().last().clone(true);
        new_node.show();
        new_node.children().first().text(tag);
        element.append(new_node);
    }
});
