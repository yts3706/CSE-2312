// Kruskal's MST using union-find trees

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#define STRSIZE 26
#define strEq(A, B) (strcmp(A, B) == 0)
//#define more(A, B) (A > B)
//#define less(A, B) (A < B)
//#define eq(A, B) (A == B)

char NULLchar = '\0'; // null character
int totalNames = 0;
int HTSIZE;
int numVertices,numEdges;
int *parent,*weight,numTrees;

struct edge {
  int tail,head,weight;
};
typedef struct edge edgeType;
edgeType *edgeTab;


int find(int x)
// Find root of tree containing x
{
    int i,j,root;

    // Find root
    for (i=x;
         parent[i]!=i;
         i=parent[i])
      ;
    root=i;
    // path compression - make all nodes on path
    // point directly at the root
    for (i=x;
         parent[i]!=i;
         j=parent[i],parent[i]=root,i=j)
      ;
    return root;
}

void unionFunc(int i,int j)
// i and j must be roots!
{
    if (weight[i]>weight[j])
    {
      parent[j]=i;
      weight[i]+=weight[j];
    }
    else
    {
      parent[i]=j;
      weight[j]+=weight[i];
    }
    numTrees--;
}

int weightAscending(const void* xin, const void* yin)
// Used in call to qsort()
{
    edgeType *x,*y;

    x=(edgeType*) xin;
    y=(edgeType*) yin;
    if (x->weight != y->weight)     //sort ascending according to weight
        return x->weight - y->weight;
    else if (x->tail != y->tail)  //sort ascending according to tail if weight equal
        return x->tail- y->tail;
    else  return x->head- y->head;  //sort ascending according to head if tail equal
}

int leader_weightAscending(const void* xin, const void* yin)
// Used in call to qsort()
{
    edgeType *x,*y;

    x=(edgeType*) xin;
    y=(edgeType*) yin;
    int leaderX = find(x->tail);
    int leaderY = find(y->tail);
    if (leaderX != leaderY)         //sort ascending according to leader
        return leaderX - leaderY;
    else  if (x->weight != y->weight)     //sort ascending according to weight if leader equal
        return x->weight - y->weight;
    else if (x->tail != y->tail)  //sort ascending according to tail if weight equal
        return x->tail- y->tail;
    else  return x->head- y->head;  //sort ascending according to head if tail equal
}

int getHashTableSize(int numEdge)
{
    int Size = numEdge + 1;

    bool prime =false;
    while (prime == false){
        prime = true;
        int i = 0;
        for ( i = 2; i<Size ; i++)
        {
            if (Size % i == 0) {
                    prime =false;
                    break;
            }
        }
        if (prime == false) Size++;
    }
    return Size;
}

int main()
{
    int i,MSTweight=0;
    int root1,root2;

    scanf("%d %d",&numVertices,&numEdges);

    //compute Hash table size base on numEdges
    HTSIZE = getHashTableSize(numEdges);
    //init hash Table
    int hashTable[HTSIZE];

    //String List
    char **names=(char**) malloc(numVertices*sizeof(char*));
    for(i = 0; i < HTSIZE; i++)
		names[i] = (char*)malloc(STRSIZE*sizeof(char));

    // initializes each number in hash Table to -1
    for(i = 0; i <= HTSIZE; i++)
	{
		//hashTable[i] = (char*)malloc(STRSIZE*sizeof(char));
		hashTable[i] = -1;
	}

    edgeTab=(edgeType*) malloc(numEdges*sizeof(edgeType));
    parent=(int*) malloc(numVertices*sizeof(int));
    weight=(int*) malloc(numVertices*sizeof(int));
    if (!edgeTab || !parent || !weight)
    {
      printf("error 2\n");
      exit(0);
    }


    char nameHead[STRSIZE], nameTail[STRSIZE];
    for (i=0;i<numEdges;i++)
    {
      scanf("%s %s %d",&nameTail,&nameHead,&edgeTab[i].weight);
      //perform hashing on nameTail and return index of string on string list
      edgeTab[i].tail = performHash(nameTail,names,hashTable,HTSIZE);
      if (totalNames > numVertices) {
            printf("Number of vertices exceeded...Exiting...");
            break;
      }
      //perform hashing on nameHead and return index of string on string list
      edgeTab[i].head = performHash(nameHead,names,hashTable,HTSIZE);    //perform hashing and return index of string on string list
      if (totalNames > numVertices) {
            printf("Number of vertices exceeded...Exiting...");
            break;
      }
    }
    printf("\n\n");
    if (totalNames <=numVertices){
        if (totalNames<numVertices) printf("Warning: continuing with only %d vertices\n",totalNames);
        for (i=0;i<numVertices;i++)
        {
          parent[i]=i;
          weight[i]=1;
        }
        numTrees=numVertices;
        //sort edges according to weight
        qsort(edgeTab,numEdges,sizeof(edgeType),weightAscending);

        i = 0;
        while (i<numEdges)
        {
          root1=find(edgeTab[i].tail);
          root2=find(edgeTab[i].head);
          if (root1==root2){
             int j;   //Overwriting edges that discarded
             for (j = i; j<numEdges-1;j++){
                edgeTab[j].tail = edgeTab[j+1].tail;
                edgeTab[j].head = edgeTab[j+1].head;
                edgeTab[j].weight = edgeTab[j+1].weight;
             }
             numEdges--;
          }
          else
          {
            MSTweight+=edgeTab[i].weight;
            unionFunc(root1,root2);
            i++;
          }
        }

        //sort edges according to leader and weight
        qsort(edgeTab,numEdges,sizeof(edgeType),leader_weightAscending);


        printf("Sum of weights of spanning edges %d\n",MSTweight);
        // print trees
        int leader = -1;
        for (i = 0; i<numEdges;i++){
            if (leader != find(edgeTab[i].tail)){
                printf("Outputting tree with leader %d\n",find(edgeTab[i].tail));
                leader = find(edgeTab[i].tail);
            }
            printf("%s %s %d\n",names[edgeTab[i].tail],names[edgeTab[i].head],
              edgeTab[i].weight);
        }
    }
}




int hash1(char key[STRSIZE], int HTSIZE)
{
    int hashValue=0,i;
    for (i = 0; i < strlen(key); i++ )
        hashValue += key[i];
	return hashValue % HTSIZE;
}

int hash2(char key[STRSIZE], int HTSIZE)
{
    int hashValue=0,i;
    for (i = 0; i < strlen(key); i++ )
        hashValue += key[i];
	return 1 + hashValue % (HTSIZE - 1);
}

int hash(char key[STRSIZE], int HTSIZE, int *ii)
{
	return (hash1(key, HTSIZE) + *ii*hash2(key, HTSIZE)) % HTSIZE;
}


int performHash(char *nameKey,char* names[], int *hashTable, int HTSIZE)
{
	int h, i, ii=0,indexReturn;
		h = hash(nameKey,HTSIZE , &ii);
		while((hashTable[h] != -1)&&(!strEq(nameKey, names[hashTable[h]])))
		{
			ii++;
			h = hash(nameKey, HTSIZE, &ii);
		}
		if (hashTable[h] == -1) {
                hashTable[h] = totalNames;
                strcpy(names[totalNames],nameKey);
                indexReturn = totalNames;
                totalNames = totalNames + 1;
		} else {indexReturn = hashTable[h]; }
        return indexReturn;
}
