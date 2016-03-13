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

void linkedListInit( QLinkedList *list, size_t nodeDataSize, QFreeFunction freeFunction )
{
	list->head = NULL;
	list->length = 0;
	list->nodeDataSize = nodeDataSize;
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

int linkedListGetSize( const QLinkedList *list )
{
	return list->length;
}

int linkedListIsEmpty( const QLinkedList *list )
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

void linkedListGetHead( const QLinkedList *list, void *outNodeData )
{
	assert( list->length > 0 );
	assert( list->head != NULL );
	memcpy( outNodeData, list->head->data, list->nodeDataSize );
}

int linkedListRemoveHead( QLinkedList *list )
{
	if ( list->length == 0 )
	{
		return 0;
	}
	QLinkedListNode *oldHead = list->head;
	list->head = oldHead->next;
	list->length--;
	linkedListFreeNode( list, oldHead );
	return 1;
}

void linkedListInsertBefore( QLinkedList *list, void *nodeData, QCompare compare )
{
	QLinkedListNode *newNode = linkedListNewNode( list, nodeData );

	QLinkedListNode *previous = NULL;
	QLinkedListNode *current = list->head;
	while ( current != NULL )
	{
		if ( compare( nodeData, current->data ) )
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

int linkedListFind( const QLinkedList *list, QPredicate predicate, void *predicateData, void *outNodeData )
{
	QLinkedListNode *current = list->head;
	while ( current != NULL )
	{
		if ( predicate( current->data, predicateData ) )
		{
			if ( outNodeData != NULL )
			{
				memcpy( outNodeData, current->data, list->nodeDataSize );
			}
			return 1;
		}
		current = current->next;
	}
	return 0;
}

int linkedListRemove( QLinkedList *list, QPredicate predicate, void *predicateData )
{
	QLinkedListNode *previous = NULL;
	QLinkedListNode *current = list->head;
	while ( current != NULL )
	{
		if ( predicate( current->data, predicateData ) )
		{
			if ( previous == NULL )
			{
				list->head = current->next;
			}
			else
			{
				previous->next = current->next;
			}
			list->length--;
			return 1;
		}
		previous = current;
		current = current->next;
	}
	return 0;
}
