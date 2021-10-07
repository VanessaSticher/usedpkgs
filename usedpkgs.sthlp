{smcl}
{* *! version 1.0.0 07October2021}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "mypkg" "help mypkg"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "usedpkgs##syntax"}{...}
{viewerjumpto "Description" "usedpkgs##description"}{...}
{viewerjumpto "Options" "usedpkgs##options"}{...}
{viewerjumpto "Examples" "usedpkgs##examples"}{...}
{viewerjumpto "Stored results" "usedpkgs##results"}{...}
{viewerjumpto "Authors" "usedpkgs##contact"}{...}
{viewerjumpto "Acknowledgements" "usedpkgs##acknowledgements"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:usedpkgs} {hline 2}}List all packages used in a do-file{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}


{p 8 15 2} {cmd:usedpkgs} [{it:{help filename}}] [{cmd:,} {help usedpkgs##options_table:options}]{p_end}


{marker options_table}{...}
{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Ado folder}
{synopt: {opt keepfolder}}Keep the new folder with the ado files{p_end}

{syntab:List of packages}
{synopt : {opt replace}}Replace the txt file with the listing the ado files and the ado folder{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:usedpkgs} creates a list of all packages used in a do-file.

{pstd}
For listing all packages (not specific to a do-file), use {help mypkg}.


{marker options}{...}
{title:Options}

{marker opt_folder}{...}
{dlgtab:Ado folder}

{phang}
{opt keepfolder} keeps the newly created folder with the ado files. The folder is located in the current directory and named {it:ado_usedpkgs}.

{marker opt_list{...}
{dlgtab:List of packages}

{phang}
{opt replace} replaces an existing list of ado files. The list is stored in a txt file named {it:file_ados.txt} in the current directory.


{marker examples}{...}
{title:Examples}

{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Find the packages required to run the do-file {it:example.do}{p_end}
{phang2}{cmd:. usedpkgs example.do}{p_end}
{hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:reghdfe} stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:e(add_name)}}add_descriptopn{p_end}


{marker contact}{...}
{title:Authors}

{pstd}Vanessa Sticher{break}
{p_end}



{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
Add acknowledgements here.{p_end}

