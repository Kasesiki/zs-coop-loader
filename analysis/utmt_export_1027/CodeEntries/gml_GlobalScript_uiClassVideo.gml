uiAddBoxType("UiVideo", uiClassVideo, false);

function uiClassVideo() : __uiClassCommon() constructor
{
    queue_buffer_time = 1;
    queue_buffer_timer = 0;
    queue_video = 0;
    source = undefined;
    loop = true;
    color = 16777215;
    alpha = 1;
    backup_image = spr_videoreplacement_mainmenu;
    CallbackSetOnClose(function()
    {
        video_close();
    });
    CallbackSetDraw(function()
    {
        queue_buffer_timer = max(queue_buffer_timer - 1, 0);
        if (queue_video && queue_buffer_timer == 0)
        {
            multiplat_video_open(source);
            video_enable_loop(loop);
            queue_video = false;
        }
        var _color = merge_color(color, animBlend, animBlendAmount);
        var _alpha = alpha * animAlpha;
        var _video = video_draw();
        var rv = _video[0];
        var surf = _video[1];
        var chromasurf = _video[2];
        var drawInYUV = false;
        if (rv == 0 && !global.is_steamdeck && surface_exists(surf))
        {
            if (drawInYUV)
            {
                if (rv == 0 && surface_exists(surf) && surface_exists(chromasurf))
                {
                    shader_set(shd_videochroma_switch);
                    var tex_id = surface_get_texture(surf);
                    var chroma_tex_id = surface_get_texture(chromasurf);
                    texture_set_stage(videochromasampler, chroma_tex_id);
                    gpu_set_texfilter(false);
                    draw_primitive_begin_texture(pr_trianglestrip, tex_id);
                    draw_vertex_texture(0, 0, 0, 0);
                    draw_vertex_texture(__localRight - __localLeft, 0, 1, 0);
                    draw_vertex_texture(0, __localBottom - __localTop, 0, 1);
                    draw_vertex_texture(__localRight - __localLeft, __localBottom - __localTop, 1, 1);
                    draw_primitive_end();
                    shader_reset();
                }
            }
            else
            {
                draw_surface_stretched_ext(surf, __drawLeft, __drawTop, __localRight - __localLeft, __localBottom - __localTop, _color, _alpha);
            }
        }
        else
        {
            draw_sprite_stretched_ext(backup_image, 0, __drawLeft, __drawTop, __localRight - __localLeft, __localBottom - __localTop, _color, _alpha);
            video_close();
            if (!queue_video && rv == -1 && !global.is_steamdeck)
            {
                queue_buffer_timer = queue_buffer_time;
                queue_video = true;
            }
        }
    });
}
