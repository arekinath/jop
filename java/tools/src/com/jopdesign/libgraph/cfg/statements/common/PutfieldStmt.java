/*
 * Copyright (c) 2007,2008, Stefan Hepp
 *
 * This file is part of JOPtimizer.
 *
 * JOPtimizer is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * JOPtimizer is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.jopdesign.libgraph.cfg.statements.common;

import com.jopdesign.libgraph.cfg.statements.FieldStmt;
import com.jopdesign.libgraph.struct.ClassInfo;
import com.jopdesign.libgraph.struct.ConstantField;
import com.jopdesign.libgraph.struct.FieldInfo;

/**
 * @author Stefan Hepp, e0026640@student.tuwien.ac.at
 */
public abstract class PutfieldStmt extends AbstractStatement implements FieldStmt {

    private ConstantField fieldInfo;

    public PutfieldStmt(ConstantField fieldInfo) {
        this.fieldInfo = fieldInfo;
    }

    public ClassInfo getClassInfo() {
        return fieldInfo.getClassInfo();
    }

    public FieldInfo getFieldInfo() {
        return fieldInfo.getFieldInfo();
    }

    public ConstantField getConstantField() {
        return fieldInfo;
    }

    public boolean isStatic() {
        return fieldInfo.isStatic();
    }

    public boolean canThrowException() {
        return false;
    }

}
