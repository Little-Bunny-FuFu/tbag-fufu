This is the long awaited update to TBag that fixes a number of bugs.

TBag is a WoW Addon that provides an alternative bag and bank interface.  It was
built by modifying Engbags an addon who has essnetially the same functionality 
is missing some of the features of TBag.

Talos the original author of Tbag his this to say about it when he released it: 

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
Some of them are not terribly relevent to my my intentions, some I'm unclear on
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
upper right. It also enables you to do a full item search from the search
textbox just to the left of the name dropdown. 

Todo/Known Issues

* Shift Clicking on the backpack closes tbag and opens the blizzard frames for the
individual bags other than the backpack, regardless of the show blizzard frames
setting.  Unfortunately, there's no easy fix due to the way Blizzard is handling
that shift click.  I'll look for a better fix in the future.

* Keychain - You can set it to include the keychain slots in the tbag interface...
However, they are generally very buggy, picking up a key ends up picking up another
inventory item.  Shouldn't be too hard to fix...

* Stacking issue.  When you go to pickup a lot of items say from the mailbox you tend
to have issues with it stacking.  It'll get and stop stacking properly and cause 
inventory to fill up even if it shouldn't.  Haven't started looking for solutions 
to this yet.  High on my priority list...

* Searching.  Text results alone suck.  Should be able to use the highlighting 
like we have for new items for searches.  

* Missing items from the default groups.  With TBC many new items have been added.
In some cases they are improperly labeled and need some manual intervention to
sort properly.  Updating the list of item numbers that need special casing needs
to be done or find a library that does this for us.  PeriodicTable may be an 
option, but I'm not sure it'll be a complete solution.  In the interim people
who run into such issues should post item numbers and categories of such items
to one of the forums for addons (curse, wowinterface).

* Easier way to recatagorize single items.  Having to add a pattern to put
  a single item in a different category is annoying.  Bring back the behavior
  EngBags had of allowing you to assign items to a category via right click.

* Messy/dead code.  The addon is filled with messy and dead code.  It needs a good
clean out and review of essentially every single line.  There is a lot of code
duplication that is unnecessary.  While this is something I might like to do, it
is *NOT* a priority.  My major priorities are fixing annoying bugs and tweaking
features to be more useful.  

Contacting Me

I will do my best to check in on the addon forums from time to time.  More so
around major patch releases.  Less so between.  I certainly won't be checking
in every day.  Curse Gaming and WowInterface will be kept up to date with the
latest update and I will read the forums there.  No gurantees anywhere else.
