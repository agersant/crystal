#include <assert.h>
#include <string.h>
#include "linked_list.h"

static QLinkedListNode *linkedListNewNode( QLinkedList *list, void *nodeData )
{
	assert( nodeData != NULL );
	QLinkedListNode *newNode = malloc( sizeof( QLinkedListNode ) );
	newNode->data = malloc( list->nodeDataSize );
	memcpy( newNode->data, nodeData, list->nodeDataSize );
	return newNode;
}

static void linkedListFreeNode( QLinkedList *list, QLinkedListNode *node )
{
	assert( node != NULL );
	if ( list->freeFunction != NULL ) {
		list->freeFunction( node->data );
	}
	free( node->data );
	free( node );
}

void linkedListInit( QLinkedList *list, size_t elementSize, QFreeFunction freeFunction )
{
	list->head = NULL;
	list->length = 0;
	list->nodeDataSize = elementSize;
	list->freeFunction = freeFunction;
}

void linkedListFree( QLinkedList *list )
{
	QLinkedListNode *current;
	while( list->head != NULL ) {
		current = list->head;
		list->head = current->next;
		linkedListFreeNode( list, current );
	}
}

int linkedListGetSize( QLinkedList *list )
{
	return list->length;
}

int linkedListIsEmpty( QLinkedList *list )
{
	return list->length == 0;
}

void linkedListPrepend( QLinkedList *list, void *nodeData )
{
	assert( nodeData != NULL );
	QLinkedListNode *newNode = linkedListNewNode( list, nodeData );
	newNode->next = list->head;
	list->head = newNode;
	list->length++;
}

void linkedListGetHead( QLinkedList *list, void *outNodeData )
{
	assert( list->length > 0 );
	assert( list->head != NULL );
	memcpy( outNodeData, list->head->data, list->nodeDataSize );
}

void linkedListRemoveHead( QLinkedList *list )
{
	if ( list->length == 0 )
	{
		return;
	}
	QLinkedListNode *oldHead = list->head;
	list->head = oldHead->next;
	list->length--;
	linkedListFreeNode( list, oldHead );
}

void linkedListInsertBefore( QLinkedList *list, void *nodeData, QPredicate predicate )
{
	QLinkedListNode *newNode = linkedListNewNode( list, nodeData );

	QLinkedListNode *previous = NULL;
	QLinkedListNode *current = list->head;
	while ( current != NULL )
	{
		if ( predicate( nodeData, current ) )
		{
			break;
		}
		previous = current;
		current = current->next;
	}

	newNode->next = current;
	if ( previous == NULL )
	{
		list->head = newNode;
	}
	else
	{
		previous->next = newNode;
	}
	list->length++;
}
