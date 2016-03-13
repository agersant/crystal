#pragma once
#include <stdlib.h>

typedef struct QLinkedListNode
{
	void *data;
	struct QLinkedListNode *next;
} QLinkedListNode;

typedef void( *QFreeFunction )( void *nodeData );
typedef int( *QCompare )( void *newNodeData, void *listNodeData );
typedef int( *QPredicate )( void *nodeData, void *predicateData );

typedef struct QLinkedList
{
	size_t nodeDataSize;
	int length;
	QLinkedListNode *head;
	QFreeFunction freeFunction;
} QLinkedList;

void linkedListInit( QLinkedList *list, size_t elementSize, QFreeFunction freeFunction );
void linkedListFree( QLinkedList *list );

void linkedListPrepend( QLinkedList *list, void *nodeData );
void linkedListInsertBefore( QLinkedList *list, void *nodeData, QCompare predicate );

int linkedListGetSize( const QLinkedList *list );
int linkedListIsEmpty( const QLinkedList *list );
void linkedListGetHead( const QLinkedList *list, void *outNodeData );
int linkedListFind( const QLinkedList *list, QPredicate predicate, void *predicateData, void *outNodeData );

int linkedListRemove( QLinkedList *list, QPredicate predicate, void *predicateData );
int linkedListRemoveHead( QLinkedList *list );
