from gurobipy import Model, GRB, multidict, tuplelist, quicksum
from pandas import DataFrame, read_csv
from sys import argv

def solve(budget, buses, lines, u, c, b, S, D):
    m = Model('inhibit')
    w, v, y = {}, {}, {}
    for i in buses:
        w[i] = m.addVar(vtype=GRB.BINARY, name="w_%s" % i)
    for i, j in lines:
        v[i, j] = m.addVar(vtype=GRB.BINARY, name='v_%s_%s' % (i, j))
        y[i, j] = m.addVar(vtype=GRB.BINARY, name='y_%s_%s' % (i, j))
    m.update()

    for i, j in lines:
        m.addConstr(w[i]-w[j] <= v[i, j] + y[i, j], 'balance1_%s_%s' % (i, j))
        m.addConstr(w[j]-w[i] <= v[i, j] + y[i, j], 'balance2_%s_%s' % (i, j))
    m.addConstr(quicksum(c[i, j]*y[i, j] for i, j in lines) <= budget, 'budget')
        
    m.setObjective(quicksum(u[i, j]*v[i, j] for i, j in lines) +
                   quicksum(b[i]*(1-w[i]) for i in S) -
                   quicksum(b[i]*w[i] for i in D))
    
    m.setParam('OutputFlag', 0)
    m.optimize()
    m.write('gurobi.lp')
    return w, v, y, m
    

def main(budget=3):
    data = read_csv('temp.csv')
    s = data.groupby('fbus').p.sum()
    d = -data.groupby('tbus').p.sum()
    b = s.add(d, fill_value=0)

    x = data.set_index(['fbus', 'tbus'])
    capacities = x.to_dict()['p']
    x['costs'] = 1
    c = x.to_dict()['costs']

    buses = list(b.index)
    lines, u = multidict(capacities)
    lines = tuplelist(lines)
    S = set(b[b>0].index)
    D = set(b[b<=0].index)
    b = b.to_dict()

    w, v, y, m = solve(budget, buses, lines, u, c, b, S, D)
    if not m.status == GRB.status.OPTIMAL:
        raise RuntimeError('Gurobi did not converge, status %d' % m.status)
    for i, j in y:
        if y[i, j].x > 0:
            print('%d %d' % (i, j))

if __name__ == '__main__':
    if len(argv) < 2:
        raise RuntimeError("Usage: python max_mismatch_heuristic.py budget")
    budget = int(argv[1])
    main(budget)