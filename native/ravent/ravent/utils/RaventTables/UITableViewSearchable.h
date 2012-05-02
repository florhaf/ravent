//
//  UITableViewSearchableViewController.h
//  ravent
//
//  Created by florian haftman on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITableViewReloadable.h"

@interface UITableViewSearchable : UITableViewReloadable<UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray  *_filteredData;
    BOOL _isSearching;
}

@property (nonatomic, retain) NSMutableArray *filteredData;

@end
