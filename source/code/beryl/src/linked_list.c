#include <assert.h>
#include <string.h>
#include "linked_list.h"

static BLinkedListNode *linkedListNewNode( BLinkedList *list, void *nodeData )
{
	assert( nodeData != NULL );
	BLinkedListNode *newNode = malloc( sizeof( BLinkedListNode ) );
	newNode->data = malloc( list->nodeDataSize );
	memcpy( newNode->data, nodeData, list->nodeDataSize );
	return newNode;
}

static void linkedListFreeNode( BLinkedList *list, BLinkedListNode *node )
{
	assert( node != NULL );
	if ( list->freeFunction != NULL ) {
		list->freeFunction( node->data );
	}
	free( node->data );
	free( node );
}

void linkedListInit( BLinkedList *list, size_t nodeDataSize, BFreeFunction freeFunction )
{
	list->head = NULL;
	list->length = 0;
	list->nodeDataSize = nodeDataSize;
	list->freeFunction = freeFunction;
}

void linkedListFree( BLinkedList *list )
{
	BLinkedListNode *current;
	while( list->head != NULL ) {
		current = list->head;
		list->head = current->next;
		linkedListFreeNode( list, current );
	}
}

int linkedListGetSize( const BLinkedList *list )
{
	return list->length;
}

int linkedListIsEmpty( const BLinkedList *list )
{
	return list->length == 0;
}

void linkedListPrepend( BLinkedList *list, void *nodeData )
{
	assert( nodeData != NULL );
	BLinkedListNode *newNode = linkedListNewNode( list, nodeData );
	newNode->next = list->head;
	list->head = newNode;
	list->length++;
}

void linkedListGetHead( const BLinkedList *list, void *outNodeData )
{
	assert( list->length > 0 );
	assert( list->head != NULL );
	memcpy( outNodeData, list->head->data, list->nodeDataSize );
}

int linkedListRemoveHead( BLinkedList *list )
{
	if ( list->length == 0 )
	{
		return 0;
	}
	BLinkedListNode *oldHead = list->head;
	list->head = oldHead->next;
	list->length--;
	linkedListFreeNode( list, oldHead );
	return 1;
}

void linkedListInsertBefore( BLinkedList *list, void *nodeData, BCompare compare )
{
	BLinkedListNode *newNode = linkedListNewNode( list, nodeData );

	BLinkedListNode *previous = NULL;
	BLinkedListNode *current = list->head;
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

int linkedListFind( const BLinkedList *list, BPredicate predicate, void *predicateData, void *outNodeData )
{
	BLinkedListNode *current = list->head;
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

int linkedListRemove( BLinkedList *list, BPredicate predicate, void *predicateData )
{
	BLinkedListNode *previous = NULL;
	BLinkedListNode *current = list->head;
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
