menu_input_read();
if (current_page == MenuPage.OPTIONS) menu_options_refresh_labels();
if (rebind_index >= 0) {
    menu_notice_timer = max(0, menu_notice_timer - 1);
    menu_rebind_update();
    exit;
}
menu_navigation_update();
menu_actions_update();
