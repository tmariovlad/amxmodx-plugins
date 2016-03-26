#include <amxmodx>

#pragma semicolon 1
#define ID_TASK 1235215

#define PLUGIN "Start Gather"
#define VERSION "1.3"
#define AUTHOR "Vlad & Adryyy"

/* 
 * Seteaza numele fisierului de gather care trebuie activat
 *
 */
#define GATHER_PLUGIN_NAME "LLG-Gather.amxx"

/* 
 * Seteaza in a cata zi din saptamana trebuie sa porneasca pluginul
 * 0 = duminica
 * 1 = luni
 * 2 = marti
 * 3 = miercuri
 * 4 = joi
 * 5 = vineri
 * 6 = sambata
 */
#define GATHER_DAY "5" 

/* 
 * Seteaza ora de pornire a pluginului
 *
 */
#define GATHER_HOUR_START 20

/* 
 * Seteaza ora de oprire a pluginului
 *
 */
#define GATHER_HOUR_END 22
new bool:plugin_on = true;

public plugin_init()
{		
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public plugin_cfg() {
	// verifica daca pluginul a fost adaugat in plugins.ini
	if(is_plugin_loaded(GATHER_PLUGIN_NAME, true) == -1) {
		new error_msg[128];
		formatex(error_msg, charsmax(error_msg), "Pluginul %s nu exista in /addons/amxmodx/config/plugins.ini", GATHER_PLUGIN_NAME);
		set_fail_state(error_msg);
	}
	// verifica daca pluginul exista in /plugins
	else if(is_gather_plugin_active()==-1) {
		new error_msg[128];
		formatex(error_msg, charsmax(error_msg), "Pluginul %s nu exista in /addons/amxmodx/plugins", GATHER_PLUGIN_NAME);
		set_fail_state(error_msg);
	}
	
		
	// porneste verificarea instant
	check();
	
	// programeaza verificarea dupa 60 sec, apoi repet-o
	set_task(60.0, "check", ID_TASK, _, _, "b");
}

public check()
{
	
	new preluare_ora[3], ora;
	new CurrentDay[2];
	
	// afla care este ora curenta
	get_time("%H", preluare_ora, charsmax(preluare_ora));
	ora = str_to_num(preluare_ora);
	
	
	// afla ziua curenta
	get_time("%w", CurrentDay, charsmax(CurrentDay));
	
	server_print("CurrentDay = %s", CurrentDay);
	server_print("ora = %d", ora);
	
	// daca nu este ziua gatherului opreste pluginul de verificare
	if(!(equali(CurrentDay, "5"))) {
		if(is_gather_plugin_active() == 1) {
			pause("dc", GATHER_PLUGIN_NAME);
		}
		remove_task(ID_TASK);
		pause("ad");
	}
	
	
	if(plugin_on && ora < GATHER_HOUR_START) {
		if(is_gather_plugin_active() == 1) {
			server_print("0-deactivate too early");
			pause("c",GATHER_PLUGIN_NAME);
			plugin_on = false;
		}
	}

	
	server_print("is_gather_plugin_active() = %d", is_gather_plugin_active());
	server_print("1-checking");
	if(ora >= GATHER_HOUR_END) {
		server_print("4-deactivate");
		if(is_gather_plugin_active() == 1) {
			server_print("[ Gather LLG >> AMXX ] Fiind trecut de ora %d:00 , Oprim Gather-ul LLG ! [ >> GATHER INACTIV << ]", GATHER_HOUR_END);
			pause("dc",GATHER_PLUGIN_NAME);
			remove_task(ID_TASK);
			pause("ad");			
		}
	}
	else if(ora >= GATHER_HOUR_START)
	{
		server_print("2-is in schedule");
		
		if(is_gather_plugin_active() == 0) {
			if (unpause("ac",GATHER_PLUGIN_NAME))
			{
				server_print("[ Gather LLG >> AMXX ] Fiind trecut de ora %d:00 , Pornim Gather-ul LLG ! [ >> GATHER ACTIV << ]", GATHER_HOUR_START);
				set_task(1.0, "change_map");
			}
			else
			{
				new error_msg[128];
				formatex(error_msg, charsmax(error_msg), "[ Gather LLG >> AMXX ] Pluginul %s nu poate fi pornit (e corect numele?)", GATHER_PLUGIN_NAME);
				set_fail_state(error_msg);
			}
			
		}
		else {
			server_print("3-already active");
		}
	}
}


public change_map()
{
	server_cmd("amx_map de_dust2");
}

public is_gather_plugin_active() {
	new status[8];
	new plugin_id = find_plugin_byfile(GATHER_PLUGIN_NAME);
	get_plugin(plugin_id, _, 0, _, 0, _, 0, _, 0, status, charsmax(status));
	
	switch (status[0])
	{
		// "running"
		case 'r':
		{
			return 1;
		}
		
		// "debug"
		case 'd':
		{
			return 1;
		}
		
		// "stopped"
		case 's':
		{
			return 0;
		}	
		
		// "paused"
		case 'p':
		{
			return 0;
		}
		
		// "bad load"
		case 'b':
		{
			return -1;
		}
	}
	return 0;
}