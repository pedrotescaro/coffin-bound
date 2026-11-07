/// @description Enquadramento 16:9 independente da dimensão física da janela.
cam = view_camera[0];
camera_set_view_size(cam, 480, 270);
view_w = 480;
view_h = 270;
follow_x = 0;
follow_y = 0;
look_ahead_x = 0;
shake_timer = 0;
shake_amount = 0;
cb_camera_snap();
