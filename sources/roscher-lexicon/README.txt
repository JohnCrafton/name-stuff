==================================================

AN INDEX TO ROSCHER'S LEXICON OF MYTHOLOGY

compiled by Jonathan Groß
https://orcid.org/0000-0002-2564-9530
jgross85[AT]gmail[DOT]com

==================================================

1. INTRODUCTION

1.1. GENERAL DISCLAIMER

This index file was created as a private research project with the goal to make the wealth of information in Wilhelm Heinrich Roscher's "Detailed Lexicon of Greek and Roman Mythology" (Ausführliches Lexikon der griechischen und römischen Mythologie) more accessible to everyone.

Roscher's Lexicon, originally published by B. G. Teubner in Leipzig from 1884 to 1937, is the most complete resource on Greek and Roman mythological names to date and also encompasses mythological (and religious) subjects from Sumeran, Akkadian, Babylonian, Hittite, Egyptian, Celtic, Germanic and other neighbouring cultures.

The Lexicon was reprinted three times in the latter half of the 20th century (by Georg Olms in Hildesheim), even after its pictorial content had been superceded by the Lexicon Iconographicum Mythologiae Classicae (1981–1999, 2009). Unfortunately, since the last reprint in 1992/1993, Roscher's Lexicon has been out of stock at both publishers (Olms and De Gruyter Brill).

Since the late 2000s Roscher's Lexicon (the 6 main volumes and the 4 supplements) has been digitised by initiatives such as Google Books and the Internet Archive, and its contents can now be viewed (with OCR text) there. One prominent use case of these scans is the German Wikipedia, where over 2000 pages use Roscher's Lexicon as a reference with a link to a scanned page in the Internet Archive.

1.2. LICENSING

The file "RLM Index 1.0.ods" and its contents are released under the CC0 1.0 Universal License (https://creativecommons.org/publicdomain/zero/1.0/deed.en) in order to maximise its useability.

Use and reuse of this data is strongly encouraged, and two use cases have already been initiated by the author:
-https://mythogram.wikibase.cloud/wiki/Project:Roscher%27s_Lexicon_of_Mythology (presentation of the information from the index file as Linked Open Data)
-https://database.factgrid.de/wiki/FactGrid:Roschers_Lexikon_der_Mythologie (sets of entities from Mythology as described by Roscher's Lexicon)

(As of the publication of this data, both projects are still in preparation.)

Although not technically required by the licensing agreement, the author would appreciate being informed about other uses of the data.

==================================================

2. DESCRIPTION OF DATA
The index file is presented as tabular data. This file was created with LibreOffice Calc 7.6.6.3 and is stored in its native .ods format. For convenience, an .xlsx version is also provided. Both files are practically identical, but the .ods file is to be regarded as the 'original'.

Data is stored in several tabs:
(A) 'main alphabet' with the headwords of the main work (excluding addenda and corrigenda from the covers; for these see below).
(B) 'cover addenda' with the additional entries
(C) 'authors' with information on the authors
(D) 'fascicles' with information on the individual issues of the Lexicon

The Tabs are available separately as .csv files (with tab separation, hence poorly named).

Tabs A and B are almost identical in structure, with the columns:
A 	id 				= unique entry ID (not authoritative, just a means to identify individual entries)
B 	headword 		= lemma of the entry as stated by the Lexicon
C 	subject_type 	= self-adopted (unofficial) classification scheme for the subject matter of the article (again, not authoritative and in places even contentious)
D 	vol 			= volume number
E 	fascicle 		= issue number (not stated in the Lexicon itself, inferred from research)
F 	date 			= publication date of the entry (in accordance with the issue number)
G–H	col1,2 			= start and end column
I 	colspan 		= span of columns
J–M	author1,2,3,4 	= author of the entry (please refer to Tab C, column A)
N	entry_type 		= classification of entry (article, cross-reference, addendum, correction)
O	scan 			= URL to a scan of the start column in the Internet Archive
P	Wikidata 		= ID of the Wikidata item representing the subject (empty for most as of Version 1.0)
Q	FactGrid 		= ID of the FactGrid item representing the subject (empty for most as of Version 1.0)
R	Mythogram 		= ID of the Wikidata item representing the Lexicon entry (empty for all as of Version 1.0)
S	redirect_target = target headword as stated, if the entry is a cross-reference
T	remarks 		= remarks on the entry or subject (such as 'non-entity', 'duplicate', 'double lemma')

Tab B has two additional columns, which are mostly empty as of version 1.0
U	referring_to 	= target entry (in the main alphabet) of the correction or addenda
V	excerpt 		= textual excerpt from the entry

Tab C has information on the authors:
A	short_name 		= for sorting reasons
B	full_name 		= full name
C	Wikidata 		= Wikidata item
D	FactGrid 		= FactGrid item
E	Mythogram 		= Mythogram item
F	yob 			= year of birth
G	yod 			= year of death
H	vols 			= volumes contributed to
I	article_count 	= number of articles written (not counting corrections and addenda from Tab B)
J–L	namestring1,2,3 = name as written in the Lexicon
M	remarks 		= remarks on completeness and certainty of data

Tab D informs about the individual issues of the Lexicon as they appeared from 1884 to 1937:
A	no. 			= issue number
B	vol				= volume the issue belongs to
C	colspan 		= column span of the issue
D	headwords 		= headwords contained in the issue, as advertised on the cover page
E	issue_date 		= date of publication of the individual issue, as stated on the cover page
F	quires 			= quire numbers of the issue
G	quire_count 	= quire count of the issue (calculated: in some cases, at the end of a volume, quires were shortened, returning rational numbers here)
H	remarks 		= remarks (in German)

==================================================

3. VERSION HISTORY AND CHANGE LOG

--------------------------------------------------
Version 1.0
-Tabs A–B with complete and checked data for columns A–N and S
-Tab A with complete data for column O
-Tabs C and D with complete data

--------------------------------------------------
Prior to publication:
-Collection and checking of data (roughly 376 hours, starting in July 2023 and finished on Star Wars Day 2024)

==================================================