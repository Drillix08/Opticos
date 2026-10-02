#pragma once
#include <godot_cpp/classes/node.hpp>
#include <ginac/ginac.h>

namespace godot {

class GiNaCNode : public Node {
    GDCLASS(GiNaCNode, Node)

private:
    GiNaC::symbol x;
    GiNaC::symtab table;
    GiNaC::parser *reader;

    GiNaC::ex parse(const String &expr);

protected:
    static void _bind_methods();

public:
    GiNaCNode();
    ~GiNaCNode();

    String expand(String expr);
    String differentiate(String expr);
    String differentiate_nth(String expr, int n);
    String integrate(String expr);
    double integrate_definite(String expr, double a, double b);
    double evaluate(String expr, double value);
    String limit(String expr, double value);
};

}