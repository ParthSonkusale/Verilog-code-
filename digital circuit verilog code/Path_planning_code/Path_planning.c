

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#define V 32

#ifdef linux 

    #include <stdio.h>

    void _put_byte(char c) { putchar(c); }

    void _put_str(char *str) {
        while (*str) {
            _put_byte(*str++);
        }
    }

    void print_output(uint8_t num) {
        if (num == 0) {
            putchar('0');
directly print '0'
            _put_byte('\n');
            return;
        }

        if (num < 0) {
            putchar('-'); 
            num = -num;   
        }

        // convert the integer to a string
        char buffer[20]; // assuming a 32-bit integer, the maximum number of digits is 10 (plus sign and null terminator)
        uint8_t index = 0;

        while (num > 0) {
            buffer[index++] = '0' + num % 10; // convert the last digit to its character representation
            num /= 10;                        // move to the next digit
        }
        // print the characters in reverse order (from right to left)
        while (index > 0) { putchar(buffer[--index]); }
        _put_byte('\n');
    }

    void _put_value(uint8_t val) { print_output(val); }

#else 

    void _put_value(uint8_t val) { }
    void _put_str(char *str) { }

#endif


int main(int argc, char const *argv[]) {

    #ifdef linux

        const uint8_t START_POINT   = atoi(argv[1]);
        const uint8_t END_POINT     = atoi(argv[2]);
        uint8_t NODE_POINT          = 0;
        uint8_t CPU_DONE            = 0;

    #else
        // Address value of variables for RISC-V Implementation
        #define START_POINT         (* (volatile uint8_t * ) 0x02000000)
        #define END_POINT           (* (volatile uint8_t * ) 0x02000004)
        #define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
        #define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)

    #endif

  
    uint8_t path_planned[32];
    // index to keep track of the path_planned array
    uint8_t idx = 0;

   

   

   #ifdef linux
    uint32_t graph[V] = {0};   // 1D array, each entry is a bitmask
#else
    uint32_t *graph = (uint32_t *)0x02000010;  // base address for memory-mapped graph
#endif

    // Step 1: Build adjacency (based on your map connections)
    
    // You need to fill all edges from your map.
graph[0]  = (1<<1) | (1<<6) | (1<<10);
graph[1]  = (1<<0) | (1<<11)|(1<<2);
graph[2]  = (1<<3) | (1<<5) | (1<<1) | (1<<4);
graph[3]  = (1<<2);
graph[4]  = (1<<2);
graph[5]  = (1<<2);
graph[6]  = (1<<0) | (1<<7) | (1<<9) | (1<<9) | (1<<8);
graph[7]  = (1<<6);
graph[8]  = (1<<6);
graph[9]  = (1<<6);
graph[10] = (1<<0)|(1<<11)|(1<<24)|(1<<26);
graph[11] = (1<<1) | (1<<12)|(1<<10)|(1<<19);
graph[12] = (1<<11) | (1<<13) | (1<<14);
graph[13] = (1<<12);
graph[14] = (1<<12) | (1<<15) | (1<<16); 
graph[15] = (1<<14);
graph[16] = (1<<14) | (1<<17) | (1<<18);
graph[17]=(1<<16);
graph[18] =(1<<16) | (1<<21) | (1<<19);
graph[19] = (1<<11) | (1<<18) | (1<<20);
graph[20] = (1<<19);
graph[21] = (1<<18) | (1<<22) | (1<<23);
graph[22] = (1<<21);
graph[23] = (1<<21) | (1<<24) | (1<<30);
graph[24] = (1<<23) | (1<<25) | (1<<10);
graph[25] = (1<<24);
graph[26] = (1<<28) | (1<<27) | (1<<10);
graph[27] = (1<<26);
graph[28] = (1<<30) | (1<<26) | (1<<29);
graph[29] = (1<<28);
graph[30] =(1<<23) | (1<<28)| (1<<31);
graph[31] = (1<<30);

 

    // Step 2: BFS for flood fill
    bool visited[V] = {false};
    int parent[V];  // to reconstruct path
    for (int i = 0; i < V; i++) parent[i] = -1;

    int queue[V];
    int front = 0, rear = 0;
_put_str("Start: ");
    _put_value(START_POINT);
    _put_str("End: ");
    _put_value(END_POINT);
    _put_byte('\n');
    visited[START_POINT] = true;
    queue[rear++] = START_POINT;

    while (front < rear) {
        int u = queue[front++];
        _put_str("Expanding node: ");
        _put_value(u);
        if (u == END_POINT) break;
        for (int v = 0; v < V; v++) {
            if ((graph[u] & (1 << v)) && !visited[v]) {
    visited[v] = true;
    parent[v] = u;
    queue[rear++] = v;
      _put_str("  Found neighbor ");
                _put_value(v);
                _put_str("  Parent set to ");
                _put_value(u);
}
        }
    }

    // Step 3: Reconstruct path from END_POINT -> START_POINT
    int stack[V];
    int top = 0;
    for (int v = END_POINT; v != -1; v = parent[v]) {
        stack[top++] = v;
    }
     _put_str("Reconstructed (backward) path:\n");
    for (int i = 0; i < top; i++) {
        _put_value(stack[i]);
    }
    _put_byte('\n');

    // Step 4: Save path into path_planned[]
    idx = 0;
    for (int i = top - 1; i >= 0; i--) {
        path_planned[idx++] = stack[i];
    }
      _put_str("Final path (forward):\n");
    for (int i = 0; i < idx; i++) {
        _put_value(path_planned[i]);
    }
    _put_byte('\n');


   
git
    
    for (int i = 0; i < idx; ++i) {
        NODE_POINT = path_planned[i];
    }
    // Path Planning Computation Done Flag
    CPU_DONE = 1;

    #ifdef linux    // for host pc

        _put_str("######### Planned Path #########\n");
        for (int i = 0; i < idx; ++i) {
            _put_value(path_planned[i]);
        }
        _put_str("################################\n");

    #endif

    return 0;
}