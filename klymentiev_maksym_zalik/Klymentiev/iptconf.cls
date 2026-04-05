%%% --------------------------------------------------------
%%> \section{Declaration}
%%% --------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass{iptconf}{}{0.2}{IPT conference class}
\LoadClass[twocolumn, oneside]{article}[2022-06-01]

%%% --------------------------------------------------------
%%> \section{Class Options}
%%% --------------------------------------------------------


%%% --------------------------------------------------------
% \subsection{Option declarations for the document class}
%%% --------------------------------------------------------

\DeclareKeys [ iptconf ]
{
	incollection .code:n = \pagestyle{empty},
    single .code:n =
      {
        \pagestyle{plain}
        \setcounter{page}{#1}
      },

    single .default:n = 1,
}

% Set default value

\SetKeys [ iptconf ] { incollection }

\ProcessKeyOptions [iptconf]


%%% --------------------------------------------------------
%%> \section{Geometry Of Page}
%%% --------------------------------------------------------

\RequirePackage[%
	%showframe,
	a4paper,
	footskip=1cm,
	headsep=0.3cm,
	top=2cm,
	bottom=2cm,
	left=2cm,
	right=2cm,
]{geometry}
\let\@afterindentfalse\@afterindenttrue

\RequirePackage{xcolor}

%%% --------------------------------------------------------
%%> \section{Language Package}
%%% --------------------------------------------------------

\bool_lazy_or:nnTF
{ \sys_if_engine_luatex_p: }
{ \sys_if_engine_xetex_p:  }
{
	\RequirePackage{mathtools}
	\RequirePackage[default]{fontsetup}
	\RequirePackage[protrusion=true, tracking=true, babel=true]{microtype}
}
{
	\RequirePackage[T2A,T1]{fontenc}
	\RequirePackage{cmap}
	\renewcommand\sfdefault{opensans-LF}
	\renewcommand\bfdefault{b}
	\RequirePackage[protrusion=true, expansion, tracking=true, kerning=true, spacing=true, babel=true]{microtype}
	\RequirePackage{mathtools}
	\RequirePackage{amssymb}
}

\RequirePackage{csquotes}
\RequirePackage[english, russian, ukrainian]{babel}

%% In the title of the article, mathematical symbols will also be bold
\g@addto@macro\bfseries{\boldmath}

%%% --------------------------------------------------------
%%> \section{Language Dependencies}
%%% --------------------------------------------------------

%-------------------------------------------------------------------------------
% \newlanguagecommand{<cmd>}{<key=value list>}
%-------------------------------------------------------------------------------
% Defines a new language-aware command <cmd> that stores translations for
% multiple languages in a property list (prop). The command accepts an optional
% argument specifying the language code; if omitted, it uses the current language
% (\languagename).
%
% Parameters:
%   #1 - the name of the command to define (e.g. \greeting)
%   #2 - a comma-separated key=value list where keys are language codes
%        (e.g. 'english', 'russian') and values are the corresponding
%        translations.
%
% Example usage:
%   \newlanguagecommand{\greeting}{
%     english = Hello,
%     russian = Привет,
%     ukrainian = Вітаю
%   }
%
% Then \greeting[english] will expand to "Hello",
% \greeting[ukrainian] to "Привіт",
% and \greeting (without optional argument) will output the value
% for the current language (\languagename).
%
% If the translation for the requested language is not found, the
% command outputs "UNSET TRANSLATION".
%
% Implementation details:
% - Creates a new global property list named
%   g_iptconf_nlc_<command>_prop to store translations.
% - Defines the command #1 with an optional argument.
% - Uses helper functions \iptconf_nlc:Nn and \iptconf_nlc:NV
%   to fetch and return the correct translation.
%-------------------------------------------------------------------------------

\NewDocumentCommand{\newlanguagecommand}{mm}
{
	% #1 = command to define
	% #2 = key-value list with translations
	\prop_new:c { \__iptconf_nlc_strip:N #1 } % create a new prop with name derived from #1
	\prop_gset_from_keyval:cn { \__iptconf_nlc_strip:N #1 } { #2 } % set prop contents from key=value list
	\NewDocumentCommand{#1}{o}
	{
		\IfNoValueTF { ##1 }
		{
			% No language argument, use \languagename
			\iptconf_nlc:NV #1 \languagename
		}
		{
			% Language argument provided, use it
			\iptconf_nlc:Nn #1 { ##1 }
		}
	}
}

% Helper function: Given command and language code, fetch translation from the prop
\cs_new:Nn \iptconf_nlc:Nn
{
	\prop_if_in:cnTF { \__iptconf_nlc_strip:N #1 } { #2 }
	{
		\prop_item:cn { \__iptconf_nlc_strip:N #1 } { #2 }
	}
	{
		UNSET ~ TRANSLATION
	}
}

% Variant of above that takes variable for language code (N=command, V=variable)
\cs_generate_variant:Nn \iptconf_nlc:Nn { NV }

% Auxiliary macro to build the property name for storing translations
\cs_new:Nn \__iptconf_nlc_strip:N { g_iptconf_nlc_ \cs_to_str:N #1 _prop }

%%% --------------------------------------------------------
%%> \subsection{LDefinition Language Dependence Macro}
%%% --------------------------------------------------------

\newlanguagecommand{\iptbibname}{
	ukrainian={Перелік ~ використаних ~ джерел},
	russian={Перечень ~ использованных ~ источников},
	english={References}
}

\newlanguagecommand{\keyname}{
	ukrainian={Ключові ~ слова},
	russian={Ключевые ~ слова},
	english={Keywords}
}

\newlanguagecommand{\pacsnum}{
	ukrainian = PACS ~ номери,
	russian = PACS ~ номера,
	english={PACS ~ numbers}
}

\newlanguagecommand{\udcnum}{
	ukrainian={УДК},
	russian={УДК},
	english={UDC}
}

\newlanguagecommand{\ipt}{
	ukrainian={Навчально-науковий ~ Фізико-технічний ~ інститут},
	russian={Учебно-научный ~ Физико-технический ~ институт},
	english={Institute ~ of ~ Physics ~ and ~ Technology}
}

%-------------------------------------------------------------------------------
% \PaperLanguage{<language>}
%-------------------------------------------------------------------------------
% This command sets the document language for the paper, then performs
% three main actions:
%
% 1. \selectlanguage{#1} - switches the current language to the language code
%    specified by the mandatory argument #1. The language codes typically
%    correspond to languages loaded by babel or polyglossia (e.g. 'english',
%    'russian', 'ukrainian').
%
% 2. \maketitle - generates the document title using the currently active language.
%
% 3. \writeformdata - writes the registration form data (author info, title, etc.)
%    to an external file.
%
% 4. \writearticleinfo - writes additional article metadata to an external file.
%
% Usage example:
%   \PaperLanguage{ukrainian}
%
% This will produce the title, write form data and article info, all in Ukrainian.
%
% Note:
%   The macro assumes the language is properly configured with \selectlanguage
%   and that \maketitle, \writeformdata, and \writearticleinfo are defined
%   and language-sensitive as needed.
%-------------------------------------------------------------------------------
\NewDocumentCommand{ \PaperLanguage }{ m }{
	\selectlanguage{#1}
	\maketitle
	\writeformdata
	\writearticleinfo
}

%%% --------------------------------------------------------
%%> \section{Bibliography}
%%% --------------------------------------------------------

\RequirePackage[
	backend=biber,            % bibliography processing engine
	bibstyle=gost-numeric,    % GOST reference style (digital)
	sorting=none,             % order: as in a .bib file
	maxnames=10,              % maximum names in the author list before reduction
	autolang=other,           % annotation language in the bibliography: auto/lang/other
	isbn=true,                % display ISBN
	url=true,                 % display URL
	doi=true,                 % display DOI
	defernumbers=true,        % deferred numbering (only if backref is needed)
]{biblatex}

% Package biblatex has it’s own url handling.
\setcounter{biburllcpenalty}{100}
\setcounter{biburlucpenalty}{200}
\setcounter{biburlnumpenalty}{100}

%%% --------------------------------------------------------
%%> \subsection{Bibliography Typesetting}
%%% --------------------------------------------------------

\setlength\bibitemsep{0.5\itemsep}
\setlength\biblabelsep{1ex}
%\AddToHook{enddocument}[my]{\printbibliography[heading=bibintoc]}
\AddToHook{enddocument}[my]{%
	\ExplSyntaxOn
	\tl_set:Nx \l__ipt_bibname_tl { \iptconf_nlc:NV \iptbibname \languagename }
	\ExplSyntaxOff
	\printbibliography[
		%    heading=bibintoc,
		title={\l__ipt_bibname_tl}
	]
}

%%% --------------------------------------------------------
%%> \section{Lists}
%%% --------------------------------------------------------

\RequirePackage[]{enumitem}
\setlist{nosep}

%%% --------------------------------------------------------
%%> \section{Colums}
%%% --------------------------------------------------------

\RequirePackage{flushend}

\def\initialize@flushend{%
	%%
	%%  Activates flushend package functionality.
	%%
	\global\let\saved@orig@@outputdblcol\@outputdblcol
	\global\let\balanced@@outputdblcol\last@outputdblcol
	% use hook instead of patching:
	\AddToHook{enddocument}[flushend]{\let\@outputdblcol\balanced@@outputdblcol}%
	\g@addto@macro\footnoterule{\vskip\z@}%
	\savingvdiscards=\@ne
}

%%% --------------------------------------------------------
%%> \section{Speaker Regform}
%%% --------------------------------------------------------

\keys_define:nn { iptconf }
{
	fullname       .str_set:N = \l_iptconf_fullname_str,
	birthday       .str_set:N = \l_iptconf_birthday_str,
	position       .str_set:N = \l_iptconf_position_str,
	phone          .str_set:N = \l_iptconf_phone_str,
	authoremail    .str_set:N = \l_iptconf_authoremail_str,
	confsection    .str_set:N = \l_iptconf_confsection_str,
	copynum        .str_set:N = \l_iptconf_copynum_str,
	needliving     .str_set:N = \l_iptconf_needliving_str,
	needinvitanion .str_set:N = \l_iptconf_needinvitanion_str,
}

% We're only collecting data
\DeclareDocumentCommand \regform { m }
{
	\keys_set:nn { iptconf } { #1 }
}

%%% --------------------------------------------------------
%%> \section{Making Title}
%%% --------------------------------------------------------

%-----------------------------------------------------------
% Token list variables declaration
%%% --------------------------------------------------------

\tl_new:N \l_iptconf_udc_tl
% Stores the UDC (Universal Decimal Classification) code as a token list.

\tl_new:N \l_iptconf_pacs_tl
% Stores the PACS (Physics and Astronomy Classification Scheme) codes as a token list.

\tl_new:N \l_iptconf_abstract_tl
% Stores the abstract text of the article as a token list.

\tl_new:N \l_iptconf_keywords_tl
% Stores keywords related to the article as a token list.

\tl_new:N \l_iptconf_author_tl
% Stores the current author name as a token list.

\tl_new:N \l_iptconf_author_email_tl
% Stores the current author's email address as a token list.

\tl_new:N \l_iptconf_author_affiliation_tl
% Stores the current author's affiliation information as a token list.

\tl_new:N \l_iptconf_title_tl
% Stores the title of the article as a token list.

\tl_new:N \l_iptconf_affiliation_tl
% Stores affiliation text temporarily during processing as a token list.

\tl_new:N \l_iptconf_affiliation_number_tl
% Stores affiliation number (e.g., for superscripts) as a token list.

%%% --------------------------------------------------------
% Sequence variables declaration
%%% --------------------------------------------------------

\seq_new:N \g_iptconf_authors_seq
% Global sequence to store all authors formatted, e.g., with superscripted affiliation numbers.

\seq_new:N \g_iptconf_justauthors_seq
% Global sequence to store authors without additional formatting (just raw names).

\seq_new:N \g_iptconf_affiliation_seq
% Global sequence to store affiliations with superscripts and formatting, used for output.

\seq_new:N \g_iptconf_justaffiliation_seq
% Global sequence to store plain affiliation names without formatting.

%%% --------------------------------------------------------
% IO stream for table of contents or auxiliary data file
%%% --------------------------------------------------------

\iow_new:N \g_iptconf_totoc_iow
% Creates a new global write stream variable for outputting auxiliary data.

\iow_open:Nn \g_iptconf_totoc_iow {\c_sys_jobname_str.dat}
% Opens the file <jobname>.dat for writing using the previously created IO stream.
% This file can be used for storing metadata, table of contents, or other info.

\RenewDocumentCommand{\title}{ m }
{
	% #1 — Mandatory argument: document title

	% Store the title text in a local token list variable
	\tl_set:Nn \l_iptconf_title_tl {#1}

	% Write the title to an auxiliary output stream as:
	% \thispapertitle{<title>}
	%
	% This can be used for post-processing or external metadata extraction
	\iow_now:Nx \g_iptconf_totoc_iow
	{
		\iow_char:N \\thispapertitle % Literal backslash + macro name
		\iow_char:N \{               % Opening brace
		\exp_not:n {#1}              % Title text (unexpanded)
		\iow_char:N \}               % Closing brace
	}
}

\RenewDocumentCommand{\author}{ O{} m m }
{
	% #1 — Optional argument: email address (may be empty)
	% #2 — Mandatory argument: author name
	% #3 — Mandatory argument: affiliation index (e.g., "1", "2", etc.)

	% Store the author's name in a local token list variable
	\tl_set:Nn \l_iptconf_author_tl {#2}

	% Store the email in a local token list variable
	\tl_set:Nn \l_iptconf_author_email_tl {#1}

	% Store the affiliation index in a local token list variable
	\tl_set:Nn \l_iptconf_author_affiliation_tl {#3}

	% Append the author's name (unformatted) to a global sequence
	\seq_gput_right:Nn \g_iptconf_justauthors_seq {#2}

	% Append a formatted author entry to the global authors sequence:
	% - Name with affiliation superscript
	% - Optional email added via \thanks, if provided
	\seq_gput_right:Nn \g_iptconf_authors_seq
	{
		#2\textsuperscript{#3}
		\tl_if_empty:nTF {#1}
		{ } % If email is empty, do nothing
		{ \textsuperscript{,}\thanks{#1} } % Otherwise, add it as a footnote
	}

	% Write the author name to an auxiliary output stream as \thispaperauthor{<name>}
	\iow_now:Nx \g_iptconf_totoc_iow
	{
		\iow_char:N \\thispaperauthor
		\iow_char:N \{
		\exp_not:n {#2}
		\iow_char:N \}
	}
}

\NewDocumentCommand{\affiliation}{m m}
{
	% #1 — Affiliation text (e.g., university, institute, etc.)
	% #2 — Affiliation number (used as superscript index)

	% Store the affiliation text in a local token list variable
	\tl_set:Nn \l_iptconf_affiliation_tl {#1}

	% Store the affiliation number in a local token list variable
	\tl_set:Nn \l_iptconf_affiliation_number_tl {#2}

	% Append a formatted affiliation to the global affiliation sequence:
	% Format: superscripted number + space + affiliation name
	\seq_gput_right:Nn \g_iptconf_affiliation_seq
	{
		\textsuperscript{#2}\ #1
	}

	% Append the plain affiliation text to a separate global sequence
	\seq_gput_right:Nn \g_iptconf_justaffiliation_seq {#1}
}

\NewDocumentCommand{\@affiliation}{ }
{
	% \@affiliation — Outputs the list of formatted affiliations from \g_iptconf_affiliation_seq
	%
	% The affiliations are joined using line breaks with vertical space (\\[2ex]).
	% This is useful for typesetting the affiliations block in the title page.
	%
	% For example:
	%   \textsuperscript{1} Institute A
	%   \textsuperscript{2} Institute B
	% will be printed with spacing between lines.

	\seq_use:Nnnn
	\g_iptconf_affiliation_seq  % Sequence of formatted affiliations
	{\\[2ex]}           % Separator between first and second items
	{\\[2ex]}           % Separator between second and third
	{\\[2ex]}           % Separator between all others
}

\AtEndDocument
{
	% At the end of the document, write the finalization command to the output stream
	%
	% This writes the literal line: \finishauthors
	% Intended to mark the end of the list of authors in the auxiliary file
	\iow_now:Nx \g_iptconf_totoc_iow
	{
		\iow_char:N \\finishauthors
	}

	% Close the previously opened output stream to \g_iptconf_totoc_iow
	\iow_close:N \g_iptconf_totoc_iow
}

\NewDocumentCommand\authors{ }
{
	% \authors — Outputs a comma-separated list of formatted authors
	%
	% This command uses the global sequence \g_iptconf_authors_seq, which contains
	% the author entries in their final typeset form, including affiliation
	% superscripts and optional email footnotes (via \thanks).
	%
	% Example entries in \g_iptconf_authors_seq:
	%   - "John Doe\textsuperscript{1}"
	%   - "Jane Smith\textsuperscript{2,\thanks{jane@uni.edu}}"
	%
	% The \seq_use:Nnnn function is used to join the elements of the sequence:
	%   - First separator:  {,~}  → between the first and second elements
	%   - Second separator: {,~}  → between the second and third
	%   - General separator: {,~} → for all other pairs
	%
	% The ~ (non-breaking space) ensures consistent spacing after commas
	% even when followed by macros or superscripts.

	\seq_use:Nnnn \g_iptconf_authors_seq {,~} {,~} {,~}
}

\NewDocumentCommand\udc{ m }
{
	% \udc{<code>} — Stores a UDC (Universal Decimal Classification) code
	%
	% This command takes one mandatory argument and stores it in a local
	% token list variable \l_iptconf_udc_tl for later use (e.g., in document headers).
	%
	% Parameters:
	%   #1 — the UDC string to be stored, e.g., "004.021"
	%
	% The \tl_set:Nn function assigns the given text to the variable
	% without expanding it. This allows for robust handling of complex content,
	% such as macros or special characters in the UDC string.

	\tl_set:Nn \l_iptconf_udc_tl {#1}
}

\NewDocumentCommand\pacs{ m }
{
	% \pacs{<codes>} — Stores PACS (Physics and Astronomy Classification Scheme) codes
	%
	% This command takes one mandatory argument containing PACS codes
	% (e.g., "03.65.-w, 42.50.Ct") and stores it in a local token list variable
	% \l_iptconf_pacs_tl for later use, such as displaying in the document header or metadata.
	%
	% Parameters:
	%   #1 — a comma-separated list or string of PACS classification codes
	%
	% Internally, the \tl_set:Nn command assigns the given argument to the
	% token list variable \l_iptconf_pacs_tl without expanding its content.

	\tl_set:Nn \l_iptconf_pacs_tl {#1}
}

\NewDocumentCommand\keywords{m}
{
	% \keywords{<list>} — Stores a list of keywords relevant to the paper
	%
	% This command accepts a single mandatory argument that contains the list of
	% keywords (e.g., "quantum optics, entanglement, nonlinear dynamics") and
	% stores it in a local token list variable \l_iptconf_keywords_tl for later retrieval
	% and display (typically near the abstract or at the end of the paper).
	%
	% Parameters:
	%   #1 — a comma-separated or semicolon-separated list of keywords
	%
	% The \tl_set:Nn function is used to assign the raw string to the token list
	% without any expansion. This ensures that macros or special characters within
	% the keyword list are preserved as-is.

	\tl_set:Nn \l_iptconf_keywords_tl { #1 }
}

\RenewDocumentCommand\abstract{ +m }
{
	% \abstract{<text>} — Stores the abstract text of the paper
	%
	% This command redefines the standard \abstract macro to store its content
	% into a local token list variable \l_iptconf_abstract_tl. The content can be used
	% later for custom formatting or placement in the document.
	%
	% Parameters:
	%   #1 — the full text of the abstract. Since the '+' modifier is used,
	%        this argument allows paragraph breaks (verbatim-style input).
	%
	% The \tl_set:Nn command stores the abstract as-is, without expansion,
	% into the token list variable \l_iptconf_abstract_tl for later retrieval or printing.

	\tl_set:Nn \l_iptconf_abstract_tl {#1}
}

\NewDocumentCommand\@abstract{ }
{
	% \@abstract — Expands and prints the stored abstract text
	%
	% This internal command retrieves and typesets the contents of the
	% token list variable \l_iptconf_abstract_tl, which should have been previously
	% set via the \abstract{<text>} command.
	%
	% It does not perform any formatting or decoration by itself; it simply
	% outputs the raw content. Intended for use in locations where the abstract
	% is to appear (e.g., title page, metadata export).
	%
	% Returns:
	%   The literal contents of \l_iptconf_abstract_tl, as-is.

	\tl_use:N \l_iptconf_abstract_tl
}

\date{}

\RenewDocumentCommand\@maketitle{ }%
{
	% \@maketitle — Custom implementation of the document title block.
	%
	% This macro constructs the title page layout, including:
	% - PACS and UDC codes (if provided)
	% - Title (uppercase, sans-serif bold)
	% - Authors and affiliations
	%
	% Assumes prior definitions and storage of:
	%   \l_iptconf_title_tl         — title text
	%   \l_iptconf_pacs_tl          — PACS codes
	%   \l_iptconf_udc_tl           — UDC codes
	%   \g_iptconf_authors_seq      — list of authors with footnotes
	%   \g_iptconf_affiliation_seq  — formatted affiliation entries

	\newpage % Start title content on a new page

	% If PACS codes exist, typeset them with \pacsnum prefix
	\tl_if_empty:NTF \l_iptconf_pacs_tl
	{ } % Do nothing if empty
	{ \pacsnum\ \tl_use:N \l_iptconf_pacs_tl }

	% If UDC codes exist, typeset them with \udcnum prefix
	\tl_if_empty:NTF \l_iptconf_udc_tl
	{ } % Do nothing if empty
	{ \udcnum\ \tl_use:N \l_iptconf_udc_tl }

	\nopagebreak
	\null % Begin vertical space from a null box
	\vskip 1em

	\begin{center}
		% Temporarily redefine \footnote to be \thanks for use inside author names
		\let\footnote\thanks

		% Title: large, bold, sans-serif, uppercased
		{\Large\bfseries\sffamily
			\text_uppercase:n { \tl_use:N \l_iptconf_title_tl } \par
		}

		\vskip 1.5em

			% Author list: printed from \authors macro
			{\large
				\lineskip .5em
				\begin{center}
					\authors
				\end{center}
				\par
			}

		\vskip 1ex

			% Affiliation list: printed via \@affiliation
			{\@affiliation}
	\end{center}
}

\renewcommand\maketitle{\par
	\begingroup
	\iflanguage{ukrainian}%
	{\renewcommand\thefootnote{\itshape\asbuk{footnote}}}%
	{%
		\iflanguage{russian}%
		{\renewcommand\thefootnote{\itshape\asbuk{footnote}}}%
		{%
			\iflanguage{english}{\renewcommand\thefootnote{\itshape\alph{footnote}}}%
			{%
			}%
		}%
	}%
	\if@twocolumn
		\ifnum \col@number=\@ne
			\@maketitle
			\noindent\hrulefill\par
			\vspace{1.3ex}
			{\large\bfseries \abstractname}
			\begingroup
			\quotation
			\@abstract
			\endquotation
			\endgroup
			\noindent{\bfseries \keyname}:  ~  \tl_use:N \l_iptconf_keywords_tl \par
			\smallskip\noindent\hrulefill\medskip
		\else
			\twocolumn[\@maketitle
				\noindent\hrulefill\par
				\vspace{1.3ex}
				{\large\bfseries \abstractname}
				\begingroup
				\quotation
				\@abstract
				\endquotation
				\endgroup
				\vskip1em
				\noindent{\bfseries \keyname}:  ~  \tl_use:N \l_iptconf_keywords_tl \par
				\smallskip\noindent\hrulefill\bigskip
			]%
		\fi
	\else
		\newpage
		\global\@topnum\z@   % Prevents figures from going at top of page.
		\@maketitle
	\fi
	\@thanks
	\endgroup
	\setcounter{footnote}{0}%
	\global\let\thanks\relax
	\global\let\maketitle\relax
	\global\let\@maketitle\relax
	\global\let\@thanks\@empty
	\global\let\@author\@empty
	\global\let\@date\@empty
	\global\let\@title\@empty
	\global\let\title\relax
	\global\let\author\relax
	\global\let\date\relax
	\global\let\and\relax
}

%% --------------------------------------------------------
%\section{Recording the registration form and gender data}
%% --------------------------------------------------------

\iow_new:N   \g_iptconf_regform_iow

\NewDocumentCommand \writeformdata {} {
	\iow_open:Nn \g_iptconf_regform_iow { \c_sys_jobname_str-regform.txt }
	\iow_now:Nx \g_iptconf_regform_iow
	{
		\text_expand:n {Повне ~ ім'я ~ доповідача: ~ \str_use:N \l_iptconf_fullname_str}       \iow_newline:
		\text_expand:n {Дата ~ народження: ~         \str_use:N \l_iptconf_birthday_str}       \iow_newline:
		\text_expand:n {Посада ~ доповідача: ~       \str_use:N \l_iptconf_position_str}       \iow_newline:
		\text_expand:n {Телефонний ~ номер: ~        \str_use:N \l_iptconf_phone_str}          \iow_newline:
		\text_expand:n {Email: ~                     \str_use:N \l_iptconf_authoremail_str}    \iow_newline:
		\text_expand:n {Секція: ~                    \str_use:N \l_iptconf_confsection_str}    \iow_newline:
		\text_expand:n {Кількість ~ копій: ~         \str_use:N \l_iptconf_copynum_str}        \iow_newline:
		\text_expand:n {Потреба ~ в ~ житлі: ~       \str_use:N \l_iptconf_needliving_str}     \iow_newline:
		\text_expand:n {Потреба ~ в ~ запрошенні: ~  \str_use:N \l_iptconf_needinvitanion_str} \iow_newline:
	}
	\iow_close:N \g_iptconf_regform_iow
}

\NewDocumentCommand \writearticleinfo {} {

\text_declare_purify_equivalent:Nn \LaTeX {LaTeX}
\text_declare_purify_equivalent:Nn \TeX {TeX}
\text_declare_purify_equivalent:Nn \LaTeXe {LaTeX2e}

\clist_map_inline:nn
  {
    alpha, beta, gamma, delta, epsilon, zeta, eta, theta,
    iota, kappa, lambda, mu, nu, xi, omicron, pi, rho,
    sigma, tau, upsilon, phi, chi, psi, omega,
    Gamma, Delta, Theta, Lambda, Xi, Pi, Sigma, Upsilon, Phi, Psi, Omega
  }
  {
    \exp_args:Ne \text_declare_purify_equivalent:Nn
      { \cs:w ##1 \cs_end: }
      { ##1 }
  }


  % Очистка списка авторов
  \seq_clear_new:N \g_cleanauthors_seq
  \seq_map_inline:Nn \g_iptconf_justauthors_seq
  {
    \tl_set:Nn \l_tmpa_tl { ##1 }
    \regex_replace_all:nnN { [\~] } { \  } \l_tmpa_tl
    \seq_put_right:NV \g_cleanauthors_seq \l_tmpa_tl
  }

  % Preparation of title and abstract
  \tl_set_eq:NN \l_cleanabstract_tl \l_iptconf_abstract_tl
  \regex_replace_all:nnN { [\$] } { } \l_cleanabstract_tl
  \tl_set_eq:NN \l_cleantitle_tl \l_iptconf_title_tl
  \regex_replace_all:nnN { [\$] } { } \l_cleantitle_tl

  % Open the YAML file
  \iow_open:Nn \g_iptconf_regform_iow { \c_sys_jobname_str-info.yaml }

  % Title
  \iow_now:Nx \g_iptconf_regform_iow { title: ~ "\text_purify:n { \l_cleantitle_tl }" }

  % Speaker
  \iow_now:Nx \g_iptconf_regform_iow { speaker: ~ "\str_use:N \l_iptconf_fullname_str" }

  % List of authors
  \iow_now:Nn \g_iptconf_regform_iow { authors: }
  \seq_map_inline:Nn \g_cleanauthors_seq
  {
    \iow_now:Nx \g_iptconf_regform_iow { ~ - ~ "\text_purify:n {##1}" }
  }

  % List of affiliations
  \iow_now:Nn \g_iptconf_regform_iow { affiliations: }
  \seq_map_inline:Nn \g_iptconf_justaffiliation_seq
  {
    \str_if_eq:nnTF {##1} {\ipt}
    {
      \iow_now:Nn \g_iptconf_regform_iow { ~ - ~ "НН ~ ФТІ" }
    }
    {
      \iow_now:Nx \g_iptconf_regform_iow { ~ - ~ "\text_purify:n {##1}" }
    }
  }

  % Аннотация
  \iow_now:Nx \g_iptconf_regform_iow { abstract: ~ > }
  \iow_now:Nx \g_iptconf_regform_iow { ~ \text_purify:n  {\l_cleanabstract_tl } }

  \iow_close:N \g_iptconf_regform_iow
}


%%% --------------------------------------------------------
%%> \section{Sections}
%%% --------------------------------------------------------

% --- Section numbering format
\cs_gset_protected:Npn \iptconf_seccntformat:n #1
{
	\csname the#1\endcsname.\enskip
}
\cs_gset_eq:NN \@seccntformat \iptconf_seccntformat:n

% --- Style section
\cs_gset_protected:Npn \iptconf_section:
{
	\@startsection {section}{1}{\z@}%
	{-2ex \@plus -1ex \@minus -.2ex}%
	{1.3ex \@plus.2ex}%
	{\normalfont\large\bfseries\raggedright}
}

% --- Style subsection
\cs_gset_protected:Npn \iptconf_subsection:
{
	\@startsection{subsection}{2}{\z@}%
	{-3.25ex \@plus -1ex \@minus -.2ex}%
	{1.5ex \@plus .2ex}%
	{\normalfont\bfseries\raggedright}
}

% --- Wrappers for the starred versions with the addition of in TOC
\cs_new_protected:Npn \iptconf_section_star:n #1
{
	\iptconf_section:*{#1}
	\addcontentsline{toc}{section}{#1}
}

\cs_new_protected:Npn \iptconf_subsection_star:n #1
{
	\iptconf_subsection:*{#1}
	\addcontentsline{toc}{subsection}{#1}
}

% --- Main section team (star and short name)
\RenewDocumentCommand \section {s o m}
 {
  \IfBooleanTF{#1}
  {
	  \iptconf_section_star:n {#3}
  }
  {
	  \IfNoValueTF{#2}
	  { \iptconf_section: {#3} }
	  { \iptconf_section: [#2]{#3} }
  }
 }

% --- То же для subsection
\RenewDocumentCommand \subsection {s o m}
{
	\IfBooleanTF{#1}
	{
		\iptconf_subsection_star:n {#3}
	}
	{
		\IfNoValueTF{#2}
		{ \iptconf_subsection: {#3} }
		{ \iptconf_subsection: [#2]{#3} }
	}
}

%\def\@seccntformat#1{\csname the#1\endcsname.\enskip}
%\renewcommand\section{\@startsection {section}{1}{\z@}%
%  {-2ex \@plus -1ex \@minus -.2ex}%
%  {1.3ex \@plus.2ex}%
%  {\normalfont\large\bfseries\raggedright}}
%\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
%	{-3.25ex\@plus -1ex \@minus -.2ex}%
%	{1.5ex \@plus .2ex}%
%	{\normalfont\bfseries\raggedright}}

%%% --------------------------------------------------------
%%> \section{Pictures and Tables}
%%% --------------------------------------------------------

\RequirePackage[labelformat=simple]{subcaption}
\RequirePackage[labelsep=period]{caption}
\def\tabcaption{\def\@captype{table}\caption}
\def\figcaption{\def\@captype{figure}\caption}
\renewcommand\thesubfigure{(\alph{subfigure})}
\captionsetup[subfigure]{justification=centering, subrefformat=parens}

%%% --------------------------------------------------------
%%> \section{Hyperlinks}
%%% --------------------------------------------------------

\RequirePackage[colorlinks=true,
	urlcolor = blue, %Colour for external hyperlinks
	linkcolor  = red!60!black, %Colour of internal links
	citecolor  = green!50!black, %Colour of citations
	bookmarks,
	bookmarksnumbered=true,
	breaklinks=true,
	unicode,
	linktoc = all,
	hypertexnames=false,
]{hyperref}

\endinput
