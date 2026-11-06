function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        //Add your own verbs here!
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        CANCEL,
        ACTION,
        SPECIAL,
        PAUSE,
        MAP,
        PLAYER_UP,
        PLAYER_DOWN,
        PLAYER_LEFT,
        PLAYER_RIGHT,
        PLAYER_JUMP,
        PLAYER_DASH,
        PLAYER_BAT,
        MENU_ACCEPT,
        MENU_BACK,
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        NAVIGATION,
        PLAYER_MOVE,
    }
    
    InputDefineVerb(INPUT_VERB.UP,      "up",         [vk_up,    "W"],    [-gp_axislv, gp_padu]);
    InputDefineVerb(INPUT_VERB.DOWN,    "down",       [vk_down,  "S"],    [ gp_axislv, gp_padd]);
    InputDefineVerb(INPUT_VERB.LEFT,    "left",       [vk_left,  "A"],    [-gp_axislh, gp_padl]);
    InputDefineVerb(INPUT_VERB.RIGHT,   "right",      [vk_right, "D"],    [ gp_axislh, gp_padr]);
    InputDefineVerb(INPUT_VERB.ACTION,  "action",      vk_enter,            gp_face3);
    InputDefineVerb(INPUT_VERB.SPECIAL, "special",     vk_shift,            gp_face4);

    // Ações do personagem. Mantidas separadas da navegação para facilitar rebinding futuro.
    InputDefineVerb(INPUT_VERB.PLAYER_UP,    "player_up",    [vk_up,    "W"], [-gp_axislv, gp_padu]);
    InputDefineVerb(INPUT_VERB.PLAYER_DOWN,  "player_down",  [vk_down,  "S"], [ gp_axislv, gp_padd]);
    InputDefineVerb(INPUT_VERB.PLAYER_LEFT,  "player_left",  [vk_left,  "A"], [-gp_axislh, gp_padl]);
    InputDefineVerb(INPUT_VERB.PLAYER_RIGHT, "player_right", [vk_right, "D"], [ gp_axislh, gp_padr]);
    InputDefineVerb(INPUT_VERB.PLAYER_JUMP,  "player_jump",  vk_space,          gp_face1);
    InputDefineVerb(INPUT_VERB.PLAYER_DASH,  "player_dash",  "C",              gp_face2);
    InputDefineVerb(INPUT_VERB.PLAYER_BAT,   "player_bat",   "F",              gp_face3);

    // Ações exclusivas da interface. Separadas para que rebinding do menu não
    // altere os comandos de movimento do personagem no futuro.
    InputDefineVerb(INPUT_VERB.MENU_ACCEPT, "menu_accept", [vk_space, vk_enter], gp_face1);
    InputDefineVerb(INPUT_VERB.MENU_BACK,   "menu_back",   vk_escape,            gp_face2);
    
    if (INPUT_ON_SWITCH_X)
    {
        //Flip A/B over on Switch
        InputDefineVerb(INPUT_VERB.ACCEPT, "accept", undefined, gp_face2); // !!
        InputDefineVerb(INPUT_VERB.CANCEL, "cancel", undefined, gp_face1); // !!
    }
    else
    {
        InputDefineVerb(INPUT_VERB.ACCEPT, "accept", vk_space,     gp_face1);
        InputDefineVerb(INPUT_VERB.CANCEL, "cancel", vk_backspace, gp_face2);
    }
    
    if (INPUT_ON_PS5)
    {
        //`gp_select` is inaccessible on PS5
        InputDefineVerb(INPUT_VERB.MAP, "map", vk_backspace, gp_touchpadbutton);
    }
    else
    {
        InputDefineVerb(INPUT_VERB.MAP, "map", vk_backspace, gp_select);
    }
    
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
    InputDefineCluster(INPUT_CLUSTER.PLAYER_MOVE, INPUT_VERB.PLAYER_UP, INPUT_VERB.PLAYER_RIGHT, INPUT_VERB.PLAYER_DOWN, INPUT_VERB.PLAYER_LEFT, 0.15, true);
}
