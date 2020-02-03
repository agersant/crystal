#pragma once
#include <stdlib.h>

typedef struct BLinkedListNode {
	void* data;
	struct BLinkedListNode* next;
} BLinkedListNode;

typedef void (*BFreeFunction)(void* nodeData);
typedef int (*BCompare)(void* newNodeData, void* listNodeData);
typedef int (*BPredicate)(void* nodeData, void* predicateData);

typedef struct BLinkedList {
	size_t nodeDataSize;
	int length;
	BLinkedListNode* head;
	BFreeFunction freeFunction;
} BLinkedList;

void linkedListInit(BLinkedList* list, size_t elementSize, BFreeFunction freeFunction);
void linkedListFree(BLinkedList* list);

void linkedListPrepend(BLinkedList* list, void* nodeData);
void linkedListInsertBefore(BLinkedList* list, void* nodeData, BCompare predicate);

int linkedListGetSize(const BLinkedList* list);
int linkedListIsEmpty(const BLinkedList* list);
void linkedListGetHead(const BLinkedList* list, void* outNodeData);
int linkedListFind(const BLinkedList* list, BPredicate predicate, void* predicateData,
				   void* outNodeData);

int linkedListRemove(BLinkedList* list, BPredicate predicate, void* predicateData);
int linkedListRemoveHead(BLinkedList* list);
