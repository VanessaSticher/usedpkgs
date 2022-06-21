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

{p 8 15 2} {cmd:usedpkgs} [{it:{help filename}}] [{cmd:,} {opt file:name(str)} {opt folder:name(str)} {opt replace} {opt keepfolder}]{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:usedpkgs} creates a list of all packages used in a do-file. Nested do-files are allowed. Note that the do-file must not contain the command {cmd:clear all}.

{pstd}
For listing all packages (not specific to a do-file), use {help mypkg}.


{marker options}{...}
{title:Options}

{marker opt_names}{...}
{dlgtab:Custom names}

{phang}
{opt file:name(str)} specifies the name of the file listing all packages.

{phang}
{opt folder:name(str)} keeps the newly created folder containing all ado files of the packages. The folder is located in the current directory and named {it:ado_usedpkgs}.


{marker opt_others}{...}
{dlgtab:Others}

{phang}
{opt r:eplace} replaces an existing file listing the packages. The default file name is {it:packages_list.txt}. The name can be changed using the option {cmd:filename()}. The file is saved in the current directory.

{phang}
{opt keepf:older} keeps the newly created folder containing all ado files of the packages. The folder is located in the current directory and named {it:ado_usedpkgs}.


{marker examples}{...}
{title:Examples}

{hline}
{pstd}Find packages used in the do-file {it:example.do}{p_end}
{phang2}{cmd:. usedpkgs example.do}{p_end}

{hline}
{pstd}Find the packages used in multiple do-files: create a master do-file calling the do-files{p_end}
{phang2}{cmd:. usedpkgs example_master.do}{p_end}

{hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:reghdfe} stores the following in {cmd:e()}:

{synoptset 24 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:e(dofile)}}Name of the input do-file{p_end}
{synopt:{cmd:e(filename)}}Name of the file containing the list of packages{p_end}
{synopt:{cmd:e(foldername)}}Name of the folder containing the ado files (only if option {cmd:keepfolder}){p_end}


{marker contact}{...}
{title:Authors}

{pstd}Vanessa Sticher{break}
{p_end}

