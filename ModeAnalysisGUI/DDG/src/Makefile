CC=clang++
SRCS=demo.cpp ModeAnalysis.cpp ExteriorCalculus.cpp Elements.cpp HEGraph.cpp
OBJS=$(SRCS:.cpp=.o)

%.o: %.cpp
	$(CC) -c -Wall -O3 -g $< -std=c++11

.PHONY: demo
demo: $(OBJS)
	$(CC) -Wall -O3 -g -o demo.out $(OBJS)
	@echo "Build was finished."

.PHONY: clean
clean:
	rm -f *.o *.out