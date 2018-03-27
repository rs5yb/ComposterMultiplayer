name = "A composter"
description = "Let the fertalizer roll in!"
author = "Blazerdrive09 and Jd5team"
version = "1.4.85"

forumthread = ""

api_version = 6

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true

icon_atlas = "composter.xml"
icon = "composter.tex"

configuration_options =
{
	{
        name = "decaysinto",
        label = "Food Decays Into:",
        hover = "This is what the perishable items in the composter decays into (excluding eggs)",
        options =
        {
            {description="Guano", data = 1},
			{description="Manure", data = 2},
			{description="Rot", data = 3},
		},
	default = 1,
    },
}	