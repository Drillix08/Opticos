#include "ginac_node.h"
#include <godot_cpp/core/class_db.hpp>
#include <sstream>

using namespace godot;
using namespace GiNaC;

GiNaCNode::GiNaCNode() : x("x") {
    table["x"] = x;
    reader = new parser(table);
}

GiNaCNode::~GiNaCNode() {
    delete reader;
}

// Internal helper: parse a GDScript string into a GiNaC expression
ex GiNaCNode::parse(const String &expr) {
    return (*reader)(std::string(expr.utf8().get_data()));
}

void GiNaCNode::_bind_methods() {
    ClassDB::bind_method(D_METHOD("expand", "expr"), &GiNaCNode::expand);
    ClassDB::bind_method(D_METHOD("differentiate", "expr"), &GiNaCNode::differentiate);
    ClassDB::bind_method(D_METHOD("differentiate_nth", "expr", "n"), &GiNaCNode::differentiate_nth);
    ClassDB::bind_method(D_METHOD("integrate", "expr"), &GiNaCNode::integrate);
    ClassDB::bind_method(D_METHOD("integrate_definite", "expr", "a", "b"), &GiNaCNode::integrate_definite);
    ClassDB::bind_method(D_METHOD("evaluate", "expr", "value"), &GiNaCNode::evaluate);
    ClassDB::bind_method(D_METHOD("limit", "expr", "value"), &GiNaCNode::limit);
}

// Expands an expression e.g. "(x+1)^2" -> "x^2+2*x+1"
String GiNaCNode::expand(String expr) {
    std::ostringstream oss;
    oss << parse(expr).expand();
    return String(oss.str().c_str());
}

// First derivative with respect to x
String GiNaCNode::differentiate(String expr) {
    std::ostringstream oss;
    oss << parse(expr).diff(x);
    return String(oss.str().c_str());
}

// nth derivative with respect to x
String GiNaCNode::differentiate_nth(String expr, int n) {
    std::ostringstream oss;
    oss << parse(expr).diff(x, n);
    return String(oss.str().c_str());
}

// Indefinite integral with respect to x
String GiNaCNode::integrate(String expr) {
    std::ostringstream oss;
    ex e = parse(expr);
    oss << integral(x, 0, x, e).eval_integ();
    return String(oss.str().c_str());
}

// Definite integral from a to b with respect to x
double GiNaCNode::integrate_definite(String expr, double a, double b) {
    ex e = parse(expr);
    ex result = integral(x, a, b, e).eval_integ();
    return ex_to<numeric>(result.evalf()).to_double();
}

// Evaluate expression at x = value
double GiNaCNode::evaluate(String expr, double value) {
    ex e = parse(expr).subs(x == value);
    return ex_to<numeric>(e.evalf()).to_double();
}

// Limit of expression as x approaches value (via direct substitution)
String GiNaCNode::limit(String expr, double value) {
    ex e = parse(expr).subs(x == value);
    std::ostringstream oss;
    oss << e.evalf();
    return String(oss.str().c_str());
}