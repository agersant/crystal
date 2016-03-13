#pragma once
#include <stdlib.h>

typedef struct QLinkedListNode
{
	void *data;
	struct QLinkedListNode *next;
} QLinkedListNode;

typedef void( *QFreeFunction )( void *nodeData );
typedef int( *QPredicate )( QLinkedListNode *newNode, QLinkedListNode *listNode );

typedef struct QLinkedList
{
	size_t nodeDataSize;
	int length;
	QLinkedListNode *head;
	QFreeFunction freeFunction;
} QLinkedList;

void linkedListInit( QLinkedList *list, size_t elementSize, QFreeFunction freeFunction );
void linkedListFree( QLinkedList *list );

void linkedListPrepend( QLinkedList *list, void *element );
void linkedListInsertBefore( QLinkedList *list, void *element, QPredicate predicate );

int linkedListGetSize( QLinkedList *list );
int linkedListIsEmpty( QLinkedList *list );
void linkedListGetHead( QLinkedList *list, void *outElement );

void linkedListRemoveHead( QLinkedList *list );
