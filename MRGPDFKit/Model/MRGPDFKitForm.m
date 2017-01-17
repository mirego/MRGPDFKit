//
// Created by Pascal Martel on 14-12-23.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGPDFKitForm.h"
#import "MRGPDFKitDocument.h"
#import "MRGPDFKitPage.h"
#import "MRGPDFKitDictionary.h"

@implementation MRGPDFKitForm
{
    NSMutableArray *_fieldsByType[MRGPDFKitFieldTypeNumberOfFormTypes];
    NSMutableArray *_allFields;
    NSMutableDictionary *_nameTree;
}

- (id)initWithParentDocument:(MRGPDFKitDocument *)parent
{
    self = [super init];
    if(self != nil)
    {
        for(NSUInteger i = 0 ; i < MRGPDFKitFieldTypeNumberOfFormTypes; i++) {
            _fieldsByType[i] = [[NSMutableArray alloc] init];
        }
        _allFields = [[NSMutableArray alloc] init];
        _nameTree = [[NSMutableDictionary alloc] init];
        _document = parent;
        NSMutableDictionary *pmap = [NSMutableDictionary dictionary];
        for(MRGPDFKitPage *page in _document.pages) {
            [pmap setObject:[NSNumber numberWithUnsignedInteger:page.pageNumber] forKey:[NSNumber numberWithUnsignedInteger:(NSUInteger)(page.dictionary.dictionary)]];
        }
        for(MRGPDFKitDictionary *field in [[_document.catalog objectForKey:@"AcroForm"] objectForKey:@"Fields"]) {
            [self enumerateFields:field pageMap:pmap];
        }
    }
    return self;
}

- (void)dealloc
{
    for(NSUInteger i = 0 ; i < MRGPDFKitFieldTypeNumberOfFormTypes; i++) {
        _fieldsByType[i] = nil;
    }
}

//------------------------------------------------------------------------------
#pragma mark - Private
//------------------------------------------------------------------------------

- (NSArray *)allFields
{
    return _allFields;
}

- (void)addField:(MRGPDFKitField *)field
{
    [_fieldsByType[field.fieldType] addObject:field];
    [_allFields addObject:field];
    [self populateNameTreeNode:_nameTree withComponents:[field.name componentsSeparatedByString:@"."] final:field];
}

- (void)removeField:(MRGPDFKitField *)field
{
    [_fieldsByType[field.fieldType] removeObject:field];
    [_allFields removeObject:field];

    id current = _nameTree;
    NSArray *comps = [field.name componentsSeparatedByString:@"."];

    for(NSString *comp in comps) {
        current = [current objectForKey:comp];
    }

    [current removeObject:field];
}

- (void)enumerateFields:(MRGPDFKitDictionary *)fieldDict pageMap:(NSDictionary *)pmap
{
    if([fieldDict objectForKey:@"Subtype"])
    {
        MRGPDFKitDictionary *parent = [fieldDict objectForKey:@"Parent"];
        [self applyAnnotationTypeLeafToForms:fieldDict parent:parent pageMap:pmap];
    }
    else
    {
        for(MRGPDFKitDictionary *innerFieldDictionary in [fieldDict objectForKey:@"Kids"]) {
            MRGPDFKitDictionary *parent = [innerFieldDictionary objectForKey:@"Parent"];
            if(parent!=nil) {
                [self enumerateFields:innerFieldDictionary pageMap:pmap];
            } else {
                [self applyAnnotationTypeLeafToForms:innerFieldDictionary parent:fieldDict pageMap:pmap];
            }
        }
    }
}

- (void)applyAnnotationTypeLeafToForms:(MRGPDFKitDictionary *)leaf parent:(MRGPDFKitDictionary *)parent pageMap:(NSDictionary *)pmap
{
    NSUInteger targ = (NSUInteger)(((MRGPDFKitDictionary *)[leaf objectForKey:@"P"]).dictionary);
    leaf.parent = parent;
    
    if (targ == nil) return;
    
    id pdfPageIndexValue = [pmap objectForKey:[NSNumber numberWithUnsignedInteger:targ]];
    if (pdfPageIndexValue) {
        NSUInteger pdfPageIndex = [pdfPageIndexValue unsignedIntegerValue] - 1;
        MRGPDFKitField *form = [[MRGPDFKitField alloc] initWithFieldDictionary:leaf page:[_document.pages objectAtIndex:pdfPageIndex] parent:self];
        [self addField:form];
    }
}

- (NSArray *)formsDescendingFromTreeNode:(NSDictionary *)node
{
    NSMutableArray* ret = [NSMutableArray array];
    for(NSString* key in [node allKeys]) {
        id obj = [node objectForKey:key];

        if([obj isKindOfClass:[NSMutableArray class]]) {
            [ret addObjectsFromArray:obj];
        } else {
            [ret addObjectsFromArray:[self formsDescendingFromTreeNode:obj]];
        }
    }
    return ret;
}


- (void)populateNameTreeNode:(NSMutableDictionary *)node withComponents:(NSArray *)components final:(MRGPDFKitField *)final
{
    NSString *base = [components objectAtIndex:0];

    if([components count] == 1) {
        NSMutableArray *arr = [node objectForKey:base];
        if(arr == nil) {
            arr = [NSMutableArray arrayWithObject:final];
            [node setObject:arr forKey:base];
        } else {
            [arr addObject:final];
        }
        return;
    }

    NSMutableDictionary *dict  = [node objectForKey:base];
    if(dict == nil) {
        dict = [NSMutableDictionary dictionary];
        [node setObject:dict forKey:base];
    }

    [self populateNameTreeNode:dict withComponents:[components subarrayWithRange:NSMakeRange(1, [components count] - 1)] final:final];
}

//------------------------------------------------------------------------------
#pragma mark - Public
//------------------------------------------------------------------------------

- (NSArray *)fieldsWithName:(NSString *)name
{
    id current = _nameTree;
    NSArray* comps = [name componentsSeparatedByString:@"."];

    for(NSString *comp in comps) {
        current = [current objectForKey:comp];
        if(current == nil) {
            return nil;
        }

        if([current isKindOfClass:[NSMutableArray class]]) {
            if(comp == [comps lastObject]) {
                return current;
            } else {
                return nil;
            }
        }
    }

    return [self formsDescendingFromTreeNode:current];
}

- (NSArray *)fieldsWithType:(MRGPDFKitFieldType)type
{
    return _fieldsByType[type];
}

- (void)setValue:(NSString *)val fieldName:(NSString *)name
{
    for(MRGPDFKitField *form in [self fieldsWithName:name]) {
        if((([form.value isEqualToString:val] == NO) && (form.value!=nil || val!=nil))) {
            form.value = val;
        }
    }
}

//------------------------------------------------------------------------------
#pragma mark - NSFastEnumeration
//------------------------------------------------------------------------------

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    return [[self allFields] countByEnumeratingWithState:state objects:buffer count:len];
}

@end
