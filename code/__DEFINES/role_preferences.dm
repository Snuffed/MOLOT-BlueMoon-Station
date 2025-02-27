

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_INTEQ					"InteQ"
#define ROLE_TRAITOR				"traitor"
#define ROLE_OPERATIVE				"operative"
#define ROLE_CHANGELING				"changeling"
#define ROLE_CHANGELING_MIDROUND	"Changeling (Meteor)"
#define ROLE_WIZARD					"wizard"
#define ROLE_MALF					"malf AI"
#define ROLE_REV					"revolutionary"
#define ROLE_REV_HEAD				"Head Revolutionary"
#define ROLE_REV_SUCCESSFUL			"Victorious Revolutionary"
#define ROLE_ALIEN					"xenomorph"
#define ROLE_PAI					"pAI"
#define ROLE_CULTIST				"cultist"
#define ROLE_HERETIC				"Heretic"
#define ROLE_BLOB					"blob"
#define ROLE_NINJA					"space ninja"
#define ROLE_MONKEY					"monkey"
#define ROLE_ABDUCTOR				"abductor"
#define ROLE_REVENANT				"revenant"
#define ROLE_QAREEN					"qareen"
#define ROLE_DEVIL					"devil"
#define ROLE_SERVANT_OF_RATVAR		"servant of Ratvar"
#define ROLE_BROTHER				"blood brother"
#define ROLE_BRAINWASHED			"brainwashed victim"
#define ROLE_OVERTHROW				"syndicate mutineer"
#define ROLE_SENTIENCE          	"sentience potion spawn"
#define ROLE_ANOMALY_GHOST 			"Ectoplasmic Anomaly Ghost"
#define ROLE_MIND_TRANSFER          "mind transfer potion"
#define ROLE_POSIBRAIN              "posibrain"
#define ROLE_DRONE                  "drone"
#define ROLE_DEATHSQUAD             "deathsquad"
#define ROLE_LAVALAND               "lavaland"
#define ROLE_INTERNAL_AFFAIRS		"internal affairs agent"
#define ROLE_INTEQ_AGENT			"inteq agent"
#define ROLE_FAMILIES 				"family boss"
#define ROLE_FAMILY_HEAD_ASPIRANT 	"family head aspirant"
#define ROLE_BLOODSUCKER			"bloodsucker"
#define ROLE_SPACE_DRAGON			"Space Dragon"
#define ROLE_SLAVER					"slaver"
#define ROLE_SLAVER_LEADER			"slave master"
#define ROLE_TERROR_SPIDER			"Terror Spider"
//#define ROLE_MONSTERHUNTER			"monster hunter" Disabled for now
#define ROLE_GHOSTCAFE				"ghostcafe"
#define ROLE_GHOSTROLE				"ghostrole"
#define ROLE_MINOR_ANTAG			"minorantag"
#define ROLE_RESPAWN				"respawnsystem"
#define ROLE_SYNDICATE				"Syndicate"
//Define for disabling individual antagonists for dynamic
#define HAS_ANTAG_PREF(C,ROLE) (!(NO_ANTAG & C.prefs.toggles) && (ROLE in C.prefs.be_special))
//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_TRAITOR = /datum/game_mode/traitor,
	ROLE_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_SLAVER,
	ROLE_CHANGELING = /datum/game_mode/changeling,
	ROLE_CHANGELING_MIDROUND,
	ROLE_WIZARD = /datum/game_mode/wizard,
	ROLE_MALF,
	ROLE_REV = /datum/game_mode/revolution,
	ROLE_ALIEN,
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_MONKEY = /datum/game_mode/monkey,
	ROLE_REVENANT,
	ROLE_ABDUCTOR,
	ROLE_DEVIL = /datum/game_mode/devil,
	ROLE_SERVANT_OF_RATVAR = /datum/game_mode/clockwork_cult,
	ROLE_OVERTHROW = /datum/game_mode/overthrow,
	ROLE_INTERNAL_AFFAIRS = /datum/game_mode/traitor/internal_affairs,
	ROLE_INTEQ_AGENT = /datum/game_mode/traitor/inteq_agents,
	ROLE_SENTIENCE,
	ROLE_HERETIC = /datum/game_mode/heretics,
	ROLE_BLOODSUCKER = /datum/game_mode/bloodsucker,
	ROLE_FAMILIES = /datum/game_mode/gang,
	ROLE_SPACE_DRAGON,
	ROLE_TERROR_SPIDER,
	ROLE_SYNDICATE
	//ROLE_MONSTERHUNTER Disabled for now
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
