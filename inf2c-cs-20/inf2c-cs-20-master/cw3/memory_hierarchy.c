/*************************************************************************************|
|   1. YOU ARE NOT ALLOWED TO SHARE/PUBLISH YOUR CODE (e.g., post on piazza or online)|
|   2. Fill memory_hierarchy.c                                                        |
|   3. Do not use any other .c files neither alter mipssim.h or parser.h              |
|   4. Do not include any other library files                                         |
|*************************************************************************************/

#include "mipssim.h"

uint32_t cache_type = 0;

typedef struct CACHE
{
    int valid_bit;
    int tag;
    int *data;
} cache_block;

cache_block *array_cache;

int calculate_data_index(int byte_offset)
{
    switch (byte_offset) {
        case 0:
        return 0;
        break;

        case 4:
        return 1;
        break;
    
        case 8:
        return 2;
        break;

        case 12:
        return 3;
        break;

        default:
        assert(false);
    }
}

void memory_state_init(struct architectural_state *arch_state_ptr) {
    arch_state_ptr->memory = (uint32_t *) malloc(sizeof(uint32_t) * MEMORY_WORD_NUM);
    memset(arch_state_ptr->memory, 0, sizeof(uint32_t) * MEMORY_WORD_NUM);
    if (cache_size == 0) {
        // CACHE DISABLED
        memory_stats_init(arch_state_ptr, 0); // WARNING: we initialize for no cache 0
    } else {
        // CACHE ENABLED
       // assert(0); /// @students: remove assert and initialize cache
        
        /// @students: memory_stats_init(arch_state_ptr, X); <-- fill # of tag bits for cache 'X' correctly
        
        switch(cache_type) {
        case CACHE_TYPE_DIRECT: // direct mapped
        {
            int number_words = cache_size / 4;
            int number_blocks = number_words / 4;

            int index_bits = 0;

            while (number_blocks > 1) {
            number_blocks /= 2;
            index_bits++;
            }

         number_blocks = number_words / 4;

            int var = 32 - (index_bits + 2 + 2);

            memory_stats_init(arch_state_ptr, var);

            array_cache = calloc(number_blocks, sizeof(cache_block));

            int i = 0;

            while (i < number_blocks) {
                cache_block block = {.valid_bit = 0};
                array_cache[i].data = calloc(4, sizeof(int));
                i++;
            }
         } 
        break;
        case CACHE_TYPE_FULLY_ASSOC: // fully associative
            break;
        case CACHE_TYPE_2_WAY: // 2-way associative
            break;
        }
    }
}

// returns data on memory[address / 4]
int memory_read(int address){
    arch_state.mem_stats.lw_total++;
    check_address_is_word_aligned(address);

    if (cache_size == 0) {
        // CACHE DISABLED
        return (int) arch_state.memory[address / 4];
    } else {
        // CACHE ENABLED
        //assert(0); /// @students: Remove assert(0); and implement Memory hierarchy w/ cache
        
        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.lw_cache_hits
        
        switch(cache_type) {
        case CACHE_TYPE_DIRECT: // direct mapped 
        {
            /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.lw_cache_hits
        int number_words = cache_size / 4;
        int number_blocks = number_words / 4;

        int index_bits = 0;

        while (number_blocks > 1)
        {
            number_blocks /= 2;
            index_bits++;
        }

        number_blocks = number_words / 4;

        int byte_offset = get_piece_of_a_word(address, 0, 4);
        int index = get_piece_of_a_word(address, 4, index_bits);
        int tag = get_piece_of_a_word(address, 4 + index_bits, arch_state.bits_for_cache_tag);

        int data_index = calculate_data_index(byte_offset);

        cache_block *block = &array_cache[index % number_blocks];

        if (block->valid_bit && tag == block ->tag) { 
            arch_state.mem_stats.lw_cache_hits++;
            return (int)block->data[data_index];
        }

        block->valid_bit = 1;
        block->tag = tag;

        int block_start_address = address - (data_index * 4);

        block->data[0] = (int)arch_state.memory[(block_start_address + 0) / 4];
        block->data[1] = (int)arch_state.memory[(block_start_address + 4) / 4];
        block->data[2] = (int)arch_state.memory[(block_start_address + 8) / 4];
        block->data[3] = (int)arch_state.memory[(block_start_address + 12) / 4];

        return (int)arch_state.memory[address / 4];
        }
            break;
        case CACHE_TYPE_FULLY_ASSOC: // fully associative
            break;
        case CACHE_TYPE_2_WAY: // 2-way associative
            break;
        }
    }
    return 0;
}

// writes data on memory[address / 4]
void memory_write(int address, int write_data) {
    arch_state.mem_stats.sw_total++;
    check_address_is_word_aligned(address);

    if (cache_size == 0) {
        // CACHE DISABLED
        arch_state.memory[address / 4] = (uint32_t) write_data;
    } else {
        // CACHE ENABLED
        //assert(0); /// @students: Remove assert(0); and implement Memory hierarchy w/ cache
        
        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.sw_cache_hits
        
        switch(cache_type) {
        case CACHE_TYPE_DIRECT: // direct mapped
        {
               // CACHE ENABLED
        //assert(0); /// @students: Remove assert(0); and implement Memory hierarchy w/ cache

        /// @students: your implementation must properly increment: arch_state_ptr->mem_stats.sw_cache_hits
        int number_words = cache_size / 4;
        int number_blocks = number_words / 4;

        int index_bits = 0;

        while (number_blocks > 1)
        {
            number_blocks /= 2;
            index_bits++;
        }

        number_blocks = number_words / 4;

        int byte_offset = get_piece_of_a_word(address, 0, 4);
        int index = get_piece_of_a_word(address, 4, index_bits);
        int tag = get_piece_of_a_word(address, 4 + index_bits, arch_state.bits_for_cache_tag);

        int data_index = calculate_data_index(byte_offset);

        cache_block *block = &array_cache[index % number_blocks];

        if (block->valid_bit && tag == block->tag) {
            arch_state.mem_stats.sw_cache_hits++;
            block->data[data_index] = (uint32_t)write_data;
            arch_state.memory[address / 4] = (uint32_t)write_data;
        }

     
        arch_state.memory[address / 4] = (uint32_t)write_data;
        }
            break;
        case CACHE_TYPE_FULLY_ASSOC: // fully associative
            break;
        case CACHE_TYPE_2_WAY: // 2-way associative
            break;
        }
    }
}
