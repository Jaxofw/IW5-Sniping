#include "ui_mp/includes/utility.inc"

#define BUTTON_X_START					56
#define BUTTON_Y_START					105
#define BUTTON_X_SIZE					200
#define BUTTON_Y_SIZE					25
#define BUTTON_X_SPACING				( BUTTON_X_SIZE + 4 )
#define BUTTON_Y_SPACING				( BUTTON_Y_SIZE + 4 )
#define BUTTON_COL( idx )				( ( idx - 0 - ( ( idx - 0 ) % 24 ) ) / 24 )
#define BUTTON_ROW( idx )				( ( idx - 0 ) % 24 )
#define BUTTON_X_POS( idx )				( BUTTON_X_START + BUTTON_X_SPACING * BUTTON_COL( idx ) )
#define BUTTON_Y_POS( idx )				( BUTTON_Y_START + BUTTON_Y_SPACING * BUTTON_ROW( idx ) )
#define BUTTON_ORIGIN( idx )			( BUTTON_X_POS( idx ) + 2 ) BUTTON_Y_POS( idx )
#define BUTTON_RECT( idx )				BUTTON_ORIGIN( idx ) 170 BUTTON_Y_SIZE ITEM_ALIGN

#define ARCANE_MENU( blurworld_ ) \
	focuscolor 			1 1 1 1 \
	blurworld 			blurworld_ \
	CREATE_SHADER( 106 0 151 480 0 0, "white", 0 0 0 0.5 ) \
	CREATE_SHADER( 257 0 1 480 0 0, "white", COLOR_ARCANE 0.7 ) \
	CREATE_SHADER( 118 51 34 46 0 0, "ui_square_round", 0 0 0 0.5 ) \
	CREATE_SHADER( 63 56.5 35 35 1 0, LEVEL_IMAGE, 1 1 1 1 ) \
	CREATE_TEXT( 111 71 36 36 1 0, "Welcome " + dvarString( "ui_menu_playername" ), 1 1 1 1, FONT_SCALE, 0 ) \
	CREATE_TEXT( 111 83 36 36 1 0, XP_NEEDED + " XP Left Until Level " + LEVEL_NEXT, 1 1 1 1, 0.24, 0 ) \
	CREATE_SHADER( 158 87 79 4 0 0, "ui_xpbar", 0 0 0 0.2 ) \
	CREATE_SHADER_EX( 158 87 79 4 0 0, "ui_xpbar", COLOR_ARCANE 1, 1, exp rect w ( 79 * LEVEL_XP_BAR ) )

#define BUTTON_ARCANE( idx, string, action_ ) \
	CREATE_SHADER( BUTTON_RECT( idx ), "ui_button", 0 0 0 0.5 ) \
	CREATE_SHADER( BUTTON_X_POS( idx ) BUTTON_Y_POS( idx ) 2 BUTTON_Y_SIZE ITEM_ALIGN, "white", COLOR_ARCANE 1 ) \
	CREATE_BUTTON_EX( BUTTON_RECT( idx ), string, 0.3, action_, 1, textalignx 8 textaligny 19 )
    
#define EQUIPABLE( idx, table, itemId ) \
	BUTTON_ARCANE( idx, tableLookup( table, 0, itemId, 3 ), scriptMenuResponse itemId )

#define ARCANE_BUTTON_PAGE( position, string, action_ ) \
	CREATE_BUTTON_EX( position, string, 0.26, close self; action_, 1, textalignx 6 textaligny 14 )

#define FOOTER \
	CREATE_SHADER( 56 388 110 20 1 0, "white", 0 0 0 0.5 ) \
	CREATE_TEXT( 62 403 36 36 1 0, "Message of the Day", 1 1 1 1, 0.32, 0 ) \
	CREATE_SHADER( 56 406 110 2 1 0, "white", COLOR_ARCANE 1 ) \
	CREATE_TEXT_EX( 61 427 170 36 1 0, dvarString( "motd" ), 1 1 1 1, 0.26, 0, 1, autowrapped )