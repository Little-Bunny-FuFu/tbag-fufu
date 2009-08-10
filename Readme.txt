This is the long awaited update to TBag that fixes a number of bugs.

TBag is a WoW Addon that provides an alternative bag and bank interface.  It was
built by modifying Engbags an addon who has essnetially the same functionality
is missing some of the features of TBag.

Talos the original author of TBag has this to say about it when he released it:

"In addition to the auto-sorting you've come to know and love, I've added many new
features, including searching for items (in mail, etc.) You can also see and use
the original default UI bags, which have slots free overlaid on top of them. There
are also many convenience features, like highlighting new items, colored spotlighting,
and purchase bank bags without having to unload the addon. A visual edit mode allows you
to rearrange categories to your taste, and an advanced customization window enables you
to completely configure every aspect of TBag."

This is a modification of his 070123 release for WoW 2.0.3.  The modificatoins were
done by Shefki.  See the Changelog file for details of the changes I made.  The
ToDo.txt file consists of ToDo items that were found in the original TBag release.
Some of them are not terribly relevent to my intentions, some I'm unclear on
what he meant and others seem to have already been fixed.  See my Todo List below.

Getting Started

TBag can only "see" something you've seen, so for every character:

1) Open your bags
2) Go to the bank
3) Check your mail
4) View your body
5) Open all your trade windows

This allows you to view the bag and bank contents of your characters at any time
(sorted according to their trade skills) by clicking the name dropdown in the
upper left. It also enables you to do a full item search from the search
textbox in the lower left corner of the bagframe.

Todo/Known Issues

* Configuration improvement.  Implement configuration that's integrated into the
  Blizzard configuration panels.

* Guild Bank support.  It'll get done but not till I can do it "right."

* Search.  Highlighting is now done, get the text results out of the chat box.

* Add item counts to tooltips.

* Skins.  Think something that looks very much like Blizzard's bags.

* Viewing modes for the body and mail info we're already caching and that's available
  from search.

* Messy/dead code.  The addon is filled with messy and dead code.  It needs a good
  clean out and review of essentially every single line.  There is a lot of code
  duplication that is unnecessary.  While this is something I might like to do, it
  is *NOT* a priority.  My major priorities are fixing annoying bugs and tweaking
  features to be more useful.

* Localization.  Localization cleanup is complete, just need translators.  If
  you're interested in translating contact me on Curse.

Contacting Me

I will do my best to check in on the addon forums from time to time.  More so
around major patch releases.  Less so between.  I certainly won't be checking
in every day.  Curse Gaming and WowInterface will be kept up to date with the
latest update and I will read the forums there.  No guarantees anywhere else.

Bug reports and feature requests should be directed to the ticket system on Curse:
http://wow.curseforge.com/projects/tbag-shefki/tickets/
