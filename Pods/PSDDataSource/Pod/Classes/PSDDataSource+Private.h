

// non-public instance properties that are accessible by subclasses
@interface PSDDataSource()
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL more;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSHashTable *delegates;
@end

//@interface PSDDataSourceSectionInfo()
//@property (nonatomic, readwrite, strong) NSString *name;
//@property (nonatomic, readwrite, strong) NSString *indexTitle;
//@property (nonatomic, readwrite, assign) NSUInteger numberOfObjects;
////@property (nonatomic, read) NSMutableArray *objects;
//@property (nonatomic, readwrite, assign) NSUInteger sortIndex;
//@end

@interface PSDDataSourceSectionInfo()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *indexTitle;
@property (nonatomic, assign) NSUInteger numberOfObjects;
@property (nonatomic, assign) NSUInteger sortIndex;
@property (nonatomic, strong) NSMutableArray *objects;

@end

