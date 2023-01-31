#define SNIPER							"mp/sniperTable.csv"
#define FONT_SCALE						0.3
#define ITEM_ALIGN						1 0
#define COLOR_ARCANE					0.18 0.36 0.82
#define COLOR_ITEM_SELECTED				0.35 0.82 0.18 1

#define XP_MAX							( int( tablelookup( "mp/ranktable.csv", 0, levelforexperiencemp( getplayerdata( "experience" ) ), 7 ) ) )
#define XP_MIN							( int( tablelookup( "mp/ranktable.csv", 0, levelforexperiencemp( getplayerdata( "experience" ) ), 2 ) ) )
#define XP_NEEDED						( XP_MAX - getplayerdata( "experience" ) )
#define LEVEL_NEXT						( int( tablelookup( "mp/rankTable.csv" , 0 , getplayercardinfo( 4 , 1 , 0 ) , 14 ) ) + 1 )
#define LEVEL_IMAGE						tablelookup( "mp/rankIconTable.csv", 0, levelforexperiencemp( getplayerdata( "experience" ) ), getplayerdata( "prestige" ) + 1 )
#define EMBLEM_IMAGE					tablelookupbyrow( "mp/cardIconTable.csv" , getplayercardinfo( 2 , 1 , 0 ) , 1 )

#define XP_PLAYER_MINUS_MIN				( int( getplayerdata( "experience" ) - XP_MIN ) )
#define XP_MAX_MINUS_MIN				( XP_MAX - XP_MIN )
#define LEVEL_XP_BAR					( int( XP_PLAYER_MINUS_MIN / XP_MAX_MINUS_MIN ) )

#define CREATE_SHADER( position, texture, forecolor_ ) \
	CREATE_SHADER_VIS( position, texture, forecolor_, 1 )

#define CREATE_SHADER_VIS( position, texture, forecolor_, visibility ) \
	CREATE_SHADER_EX( position, texture, forecolor_, visibility, ; )

#define CREATE_SHADER_EX( position, texture, forecolor_, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		style 			WINDOW_STYLE_SHADER \
		forecolor 		forecolor_ \
		exp 			material ( texture ) \
		visible 		when ( visibility ) \
		extra			\
	}

#define CREATE_TEXT( position, string, forecolor_, scale, textalign_ ) \
	CREATE_TEXT_VIS( position, string, forecolor_, scale, textalign_, 1 )

#define CREATE_TEXT_VIS( position, string, forecolor_, scale, textalign_, visibility ) \
	CREATE_TEXT_EX( position, string, forecolor_, scale, textalign_, visibility, ; )

#define CREATE_TEXT_EX( position, string, forecolor_, scale, textalign_, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		forecolor 		forecolor_ \
		textscale		scale \
		textalign		textalign_ \
		exp 			text ( string ) \
		visible 		when ( visibility ) \
		extra			\
	}

#define CREATE_BUTTON( position, string, textscale_, action_ ) \
	CREATE_BUTTON_VIS( position, string, textscale_, action_, 1 )

#define CREATE_BUTTON_VIS( position, string, textscale_, action_, visibility ) \
	CREATE_BUTTON_EX( position, string, textscale_, action_, visibility, ; )

#define CREATE_BUTTON_EX( position, string, textscale_, action_, visibility, extra ) \
	itemDef \
	{ \
		rect 			position \
		style			WINDOW_STYLE_EMPTY \
		type			ITEM_TYPE_BUTTON \
		textscale		textscale_ \
		forecolor		1 1 1 1 \
		exp 			text ( string ) \
		visible			when ( visibility ) \
		mouseEnter		{ play "mouse_over"; } \
		action 			{ play "mouse_click"; action_; } \
		extra			\
	}